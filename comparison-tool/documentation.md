District Comparison Tool
================

Last Updated: August 13, 2016

### Methodology

This document outlines our procedure for identifying similar districts. We begin with district profile data, available [here](http://www.tn.gov/education/topic/data-downloads).

We select the following information from this data:

<table>
<thead>
<tr>
<th style="text-align:left;">
District
</th>
<th style="text-align:right;">
Enrollment
</th>
<th style="text-align:right;">
Percent Black
</th>
<th style="text-align:right;">
Percent Hispanic
</th>
<th style="text-align:right;">
Percent Native American
</th>
<th style="text-align:right;">
Percent English Learners
</th>
<th style="text-align:right;">
Percent Students with Disabilities
</th>
<th style="text-align:right;">
Percent Economically Disadvantaged
</th>
<th style="text-align:right;">
Per-Pupil Expenditures
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Anderson County
</td>
<td style="text-align:right;">
6304
</td>
<td style="text-align:right;">
2.8
</td>
<td style="text-align:right;">
1.1
</td>
<td style="text-align:right;">
0.5
</td>
<td style="text-align:right;">
0.2
</td>
<td style="text-align:right;">
18.0
</td>
<td style="text-align:right;">
58.5
</td>
<td style="text-align:right;">
9535.7
</td>
</tr>
<tr>
<td style="text-align:left;">
Clinton City
</td>
<td style="text-align:right;">
894
</td>
<td style="text-align:right;">
5.7
</td>
<td style="text-align:right;">
2.8
</td>
<td style="text-align:right;">
0.3
</td>
<td style="text-align:right;">
1.0
</td>
<td style="text-align:right;">
18.1
</td>
<td style="text-align:right;">
63.4
</td>
<td style="text-align:right;">
9537.5
</td>
</tr>
<tr>
<td style="text-align:left;">
Oak Ridge City
</td>
<td style="text-align:right;">
4326
</td>
<td style="text-align:right;">
16.6
</td>
<td style="text-align:right;">
8.0
</td>
<td style="text-align:right;">
0.7
</td>
<td style="text-align:right;">
3.0
</td>
<td style="text-align:right;">
14.3
</td>
<td style="text-align:right;">
52.5
</td>
<td style="text-align:right;">
12355.5
</td>
</tr>
<tr>
<td style="text-align:left;">
Bedford County
</td>
<td style="text-align:right;">
8270
</td>
<td style="text-align:right;">
11.2
</td>
<td style="text-align:right;">
20.6
</td>
<td style="text-align:right;">
0.5
</td>
<td style="text-align:right;">
9.4
</td>
<td style="text-align:right;">
10.9
</td>
<td style="text-align:right;">
69.9
</td>
<td style="text-align:right;">
7756.2
</td>
</tr>
<tr>
<td style="text-align:left;">
Benton County
</td>
<td style="text-align:right;">
2133
</td>
<td style="text-align:right;">
3.9
</td>
<td style="text-align:right;">
2.1
</td>
<td style="text-align:right;">
0.3
</td>
<td style="text-align:right;">
0.0
</td>
<td style="text-align:right;">
18.8
</td>
<td style="text-align:right;">
50.2
</td>
<td style="text-align:right;">
9714.2
</td>
</tr>
</tbody>
</table>
We first standardize the district characteristic variables by subtracting each variable by its mean and dividing by its standard deviation. This puts variables on a common scale so that we can compare magnitudes of difference across district characteristics.

Next, based on the user's selected characteristics, the tool computes similarity scores between the selected district and all other districts. For a set of n selected characteristics {\(char_1, char_2, ..., char_n\)}, the similarity score between district *i* and district *j* is the following:

\(Similarity_{ij} = ((char_{1i} - char_{1j})^2 + (char_{2i} - char_{2j})^2 + ... + (char_{ni} - char_{nj})^2)^{1/2}\)

where \(char_{ni}\) is the standardized value of characteristic n for district i.

A similarity score between two identical districts based on the selected characteristics is zero, and a higher similarity score signifies more dissimilar districts. Thus, a district *i*'s most similar districts are those that have the lowest similarity scores.

By default, this tool presents data for the 7 most similar districts based on the selected characteristics for comparison of outcomes, ordered left to right from most to least similar. However, a district's most similar districts do not necessarily carry a high degree of similarity. The tool's secondary table presents profile data so that users can determine whether the identified most similar districts present valid comparison points. Other factors that are not accounted for by the comparison tool may also make comparison with similar districts inappropriate.

### Worked Example

Using 2015 profile data, we compute a similarity score between Davidson County and Shelby County based on the following characteristics: Enrollment, Percent Economically Disadvantaged, and Per-Pupil Expenditures. After standardizing, the district profile data for the two districts is as follows:

<table>
<thead>
<tr>
<th style="text-align:left;">
District
</th>
<th style="text-align:right;">
Enrollment
</th>
<th style="text-align:right;">
Percent Economically Disadvantaged
</th>
<th style="text-align:right;">
Per-Pupil Expenditures
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Davidson County
</td>
<td style="text-align:right;">
5.503712
</td>
<td style="text-align:right;">
0.9352843
</td>
<td style="text-align:right;">
2.432406
</td>
</tr>
<tr>
<td style="text-align:left;">
Shelby County
</td>
<td style="text-align:right;">
7.683066
</td>
<td style="text-align:right;">
1.2098110
</td>
<td style="text-align:right;">
2.158481
</td>
</tr>
</tbody>
</table>
Based on the selected characteristics of Enrollment, Percent Economically Disadvantaged, and Per-Pupil Expenditures, the similarity score for Davidson County and Shelby County is the following:

\(((5.5037124 - 7.6830662)^2 + (0.9352843 - 1.209811)^2 + (2.4324063 - 2.158481)^2)^{1/2}\)

= \(2.2135905\)

Using Enrollment, Percent Economically Disadvantaged, and Per-Pupil Expenditures as our selected characteristics, we find that Davidson County and Shelby County are each other's most similar district. However, using the secondary table we see that there are large differences between Davidson County and Shelby County in terms of Enrollment and Percent Black, Hispanic, and English Learner students:

<table>
<thead>
<tr>
<th style="text-align:left;">
Characteristic
</th>
<th style="text-align:right;">
Davidson County
</th>
<th style="text-align:right;">
Shelby County
</th>
<th style="text-align:right;">
Difference
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Enrollment
</td>
<td style="text-align:right;">
79934.0
</td>
<td style="text-align:right;">
108936.0
</td>
<td style="text-align:right;">
-29002.0
</td>
</tr>
<tr>
<td style="text-align:left;">
Per-Pupil Expenditures
</td>
<td style="text-align:right;">
11496.3
</td>
<td style="text-align:right;">
11221.6
</td>
<td style="text-align:right;">
274.7
</td>
</tr>
<tr>
<td style="text-align:left;">
Percent Black
</td>
<td style="text-align:right;">
44.3
</td>
<td style="text-align:right;">
78.4
</td>
<td style="text-align:right;">
-34.1
</td>
</tr>
<tr>
<td style="text-align:left;">
Percent Economically Disadvantaged
</td>
<td style="text-align:right;">
75.3
</td>
<td style="text-align:right;">
79.8
</td>
<td style="text-align:right;">
-4.5
</td>
</tr>
<tr>
<td style="text-align:left;">
Percent English Learners
</td>
<td style="text-align:right;">
16.2
</td>
<td style="text-align:right;">
8.3
</td>
<td style="text-align:right;">
7.9
</td>
</tr>
<tr>
<td style="text-align:left;">
Percent Hispanic
</td>
<td style="text-align:right;">
20.7
</td>
<td style="text-align:right;">
11.3
</td>
<td style="text-align:right;">
9.4
</td>
</tr>
<tr>
<td style="text-align:left;">
Percent Native American
</td>
<td style="text-align:right;">
0.2
</td>
<td style="text-align:right;">
0.1
</td>
<td style="text-align:right;">
0.1
</td>
</tr>
<tr>
<td style="text-align:left;">
Percent Students with Disabilities
</td>
<td style="text-align:right;">
12.4
</td>
<td style="text-align:right;">
12.9
</td>
<td style="text-align:right;">
-0.5
</td>
</tr>
</tbody>
</table>
Thus, we may wish to consider additional characteristics in identifying similar districts. However, regardless of the selected characteristics, Davidson County and Shelby County represent two relatively unique cases for which there are not many good comparison points among school districts in Tennessee.
