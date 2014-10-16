*! version 0.1, 16oct2014, Max Löffler <loeffler@zew.de>
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
 * 
 *
 * Copyright (C) 2014 Max Löffler <loeffler@zew.de>
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
 */
program define mvcollapse
    version 13
    syntax anything(name=clist id=clist) [aw/], by(varlist)
    
    // Fetch (rawsum) variables to deal with
    if (regexm("`clist'", "\(rawsum\) ([a-zA-Z0-9_ \-\*\?]*)")) {
        qui ds `=regexs(1)'
        local lrsum `r(varlist)'
    }
    // Fetch (mean) variables to deal with
    if (regexm("`clist'", "\(mean\) ([a-zA-Z0-9_ \-\*\?]*)")) {
        qui ds `=regexs(1)'
        local lmean `r(varlist)'
    }
    
    if ("`lrsum'`lmean'" != "") {
        local countlist
        
        // Loop over variables and add counters
        foreach var in `lrsum' `lmean' {
            if (strpos(" `countlist' ", " nm_`var'_nm ") == 0) {
                bys `by':  gen nn_`var'_nn = _N
                bys `by': egen nm_`var'_nm = count(`var')
                local countlist `countlist' nn_`var'_nn nm_`var'_nm
            }
        }
    }
    
    // Run true collapse
    collapse `clist' (mean) `countlist', by(`by')
    
    // Restore missings
    if ("`lrsum'`lmean'" != "") {
        // One missing in (rawsum)? All to missings.
        foreach var in `lrsum' {
            replace `var' = . if nn_`var'_nn > nm_`var'_nm
        }
        // One non-missing in (mean)? That's alright.
        foreach var in `lmean' {
            replace `var' = . if nm_`var'_nm == 0
        }
        // Clean up
        cap drop `countlist'
    }
end

***
