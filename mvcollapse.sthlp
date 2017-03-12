{smcl}
{* *! version 0.23, 12mar2017}{...}
{vieweralsosee "[R] collapse" "help collapse"}{...}
{viewerjumpto "Syntax" "mvcollapse##syntax"}{...}
{viewerjumpto "Description" "mvcollapse##description"}{...}
{viewerjumpto "Options" "mvcollapse##options"}{...}
{viewerjumpto "Author" "mvcollapse##author"}{...}
{viewerjumpto "License" "mvcollapse##license"}{...}
{title:Title}

{phang}
{bf:mvcollapse} {hline 2} Simple wrapper for {bf:{help collapse}}, preserves
missings


{marker syntax}{title:Syntax}

{p 8 17 2}
{cmd:mvcollapse}
{it:clist} {weight}
, {cmd:by}({varlist}) [{cmdab:l:abel}]


{marker description}{...}
{title:Description}

{pstd}
{opt mvcollapse} is a simple wrapper for Stata's built-in {bf:{help collapse}}
command that preserves missing values. If you take the sum over a group with 
missing values via {bf:{help collapse}}, Stata will evaluate to zero. If you
mean collapse a group with only missing values, Stata will evaluate to zero as
well. This makes sense when thinking how Stata calculates these statistics, but
it might be misleading in some applications. {opt mvcollapse} will set the sum
over a group to missing if the group contains any missing value. The group mean
with missing values is set to missing only if all values are missing.

{pstd}
Don't expect too much, {opt mvcollapse} only checks (mean) and (rawsum) so far.
Furthermore, you cannot use {bf:{help collapse}} (mean) foo = bar syntax, but
only specify varlists by now.


{marker options}{...}
{title:Options}

{pstd}
See options of Stata's {bf:{help collapse}} command.

{pstd}
{cmd:label} tries to preserve variable labels.


{marker author}{...}
{title:Author}

{pstd}
{cmd:mvcollapse} was written by Max Löffler ({browse "mailto:loeffler@zew.de":loeffler@zew.de}),
Centre for European Economic Research (ZEW), Mannheim, Germany. Comments and
suggestions are welcome.


{marker license}{...}
{title:License}

{pstd}
Copyright (C) 2014-2017, {browse "mailto:loeffler@zew.de":Max Löffler}

{pstd}
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

{pstd}
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

{pstd}
You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

