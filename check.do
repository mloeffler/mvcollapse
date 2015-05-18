*! version 0.21, 30apr2015, Max Loeffler <loeffler@zew.de>
/**
 * MVCOLLAPSE - SIMPLE WRAPPER FOR STATA'S COLLAPSE COMMAND, PRESERVES MISSINGS
 * 
 * Check functionality of mvcollapse command. Assert that (mean) and (rawsum)
 * work the way they are supposed to. Compare results to collapse results.
 * 
 * @package mvcollapse
 */


// Define temp files
tempfile tmp_coll tmp_mvcoll tmp_mvcmiss

// Produce benchmark results using collapse
sysuse bplong, clear
collapse (mean) mean1 = bp (rawsum) rsum1 = bp [aw=when], by(patient)
save "`tmp_coll'", replace

// Run classic collapse using mvcollapse
sysuse bplong, clear
gen mean2 = bp
gen rsum2 = bp
mvcollapse (mean) mean2 (rawsum) rsum2 [aw=when], by(patient)
save "`tmp_mvcoll'", replace

// Generate missings and collapse using mvcollapse
sysuse bplong, clear
gen mean3 = bp if when == 1
gen rsum3 = bp if when == 2
mvcollapse (mean) mean3 (rawsum) rsum3 [aw=when], by(patient)
save "`tmp_mvcmiss'", replace

// Merge all results to original data
sysuse bplong, clear
merge m:1 patient using "`tmp_coll'", assert(3) nogen
merge m:1 patient using "`tmp_mvcoll'", assert(3) nogen
merge m:1 patient using "`tmp_mvcmiss'", assert(3) nogen

// Assert that mean of collapse equals mean of mvcollapse
assert mean1 == mean2

// Assert that rawsum of collapse equals rawsum of mvcollapse
assert rsum1 == rsum2

// Assert that mvcollapse mean over missings equals non-missing data point
bys patient (when): assert mean3[_n] == bp[1]

// Assert that mvcollapse rawsum is missing in all observations
assert rsum3 == .

***
