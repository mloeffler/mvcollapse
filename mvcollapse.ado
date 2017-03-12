*! version 0.23, 12mar2017, Max Loeffler <loeffler@zew.de>
/**
 * MVCOLLAPSE - SIMPLE WRAPPER FOR STATA'S COLLAPSE COMMAND, PRESERVES MISSINGS
 * 
 * Collapse data by group just like Stata's built-in collapse command, but
 * be cautious with missing values. While Stata treats missings values as zero,
 * mvcollapse will set the sum over a group to missing if the group contains
 * missing values. The group mean with missing values is set to missing only
 * if all values are missing.
 *
 * Don't expect too much, mvcollapse only checks (mean) and (rawsum) so far.
 *
 * 2014-10-05   Initial version (v0.1)
 * 2014-10-16   Added Stata version and tagged `exp'
 * 2014-10-27   Add option to preserve variable labels (v0.2)
 * 2015-04-30   Bugfix, use weights to collapse when specified
 * 2017-03-11   Use tempvar to create missing indicators
 * 2017-03-12   Bugfix, understand basic varlists, use missing() function
 * 
 *
 * Copyright (C) 2014-2017 Max Löffler <loeffler@zew.de>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */


/**
 * @param `clist' Collapse is "(stat) varlist (stat) varlist ..."
 * @param `by'    Groups over which stat is to be calculated
 * @param `label' Specify to preserve variable labels
 */
program define mvcollapse
    version 13.0
    syntax anything(name=clist id=clist equalok) [aw], by(varlist) [Label FAST]

    // Fetch weight option
    local weight = cond("`weight'`exp'" != "", "[`weight'`exp']", "")
    
    // Fetch (rawsum) variables to deal with
    if (regexm("`clist'", "\(rawsum\) ([^\(]+)")) {
        qui ds `=regexs(1)'
        local lrsum `r(varlist)'
    }
    // Fetch (mean) variables to deal with
    if (regexm("`clist'", "\(mean\) ([^\(]+)")) {
        qui ds `=regexs(1)'
        local lmean `r(varlist)'
    }
    
    // If anything to do, create tempvars for N and non-missing N in by-group
    if ("`lrsum'`lmean'" != "") {
        // Remember N indicators for collapse command later on
        local countlist
        
        // Loop over variables and add counters
        foreach var in `lrsum' `lmean' {
            if ("`tmp_n_`var''" == "" & "`tmp_nm_`var''" == "") {
                tempvar tmp_n_`var' tmp_nm_`var'
                bys `by':  gen `tmp_n_`var''  = _N
                bys `by': egen `tmp_nm_`var'' = total(!missing(`var'))
                local countlist `countlist' `tmp_n_`var'' `tmp_nm_`var''
            }
        }
    }
    
    // Preserve labels if option specified
    if ("`label'" != "") {
        foreach var of var * {
            cap local lb`var' : var label `var'
        }
    }
    
    // Run true collapse
    di as text "collapse `clist' `weight', by(`by') `fast'"
    collapse `clist' (mean) `countlist' `weight', by(`by') `fast'
    
    // Restore labels if option specified
    if ("`label'" != "") {
        foreach var of var * {
            cap label var `var' "`lb`var''"
        }
    }
    
    // Restore missings
    if ("`lrsum'`lmean'" != "") {
        // One missing in (rawsum) by-group? Set whole by-group to missings.
        foreach var in `lrsum' {
            qui replace `var' = . if `tmp_n_`var'' > `tmp_nm_`var''
        }
        // Only missing obervations in (mean) by-group? Replace mean by missing.
        foreach var in `lmean' {
            qui replace `var' = . if `tmp_nm_`var'' == 0
        }
        // Clean up
        cap drop `countlist'
    }
end

***
