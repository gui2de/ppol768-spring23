# Spatial Mismatch in the DMV


## Introduction
"Spatial mismatch" refers to the mismatch between where suitable job opportunities exist and where job seekers reside. Studies in various geographies have found that greater mismatch exacerbates regional unemployment rates and persistent joblessness. The construction and expansion of public transit is one popular approach to reducing spatial mismatch and improving labor market outcomes.

The delayed construction of the  Purple Line (now slated to open in 2026) offers a unique opportunity for a longitudinal study of the impact of a new light-rail line on employment and socioeconomic outcomes in the Washington DC area. The Purple Line project includes 21 planned stations that will link Maryland suburbs with existing lines that run through downtown Washington DC.

![Model](https://github.com/gui2de/ppol768-spring23/blob/96b407efa9cda1a6abb0e7ef18b500a5fc88ffb2/Group%20Projects/group-1/img/purpe-line-map.png)
[Source](https://purplelinemd.com/about-the-project/project-maps)

### Problem statement:
The spatial mismatch hypothesis, popularly attributed to Kain (1968), posits that poor labor market outcomes for poor urban workers are exacerbated by a geographical mismatch between their residences and suitable job opportunities (Brueckner and Zenou 2003). Spatial mismatch comprises multiple geography-related elements, such as limited public-transit options, long commutes, limited affordable housing options near job hubs, and limited access to private transit. These issues contribute to higher regional unemployment rates and longer jobless spells among low-income workers (Andersson et al 2014).

Analysis of spatial mismatch in the Washington DC area has demonstrated similar negative impacts on labor market outcomes. One analysis of the Washington-Arlington-Alexandria metropolitan statistical area found that, from 2000 to 2012, the overall number of jobs near the average resident increased by 2 percent, but in high-poverty and "majority-minority" census tracts, the number of jobs near the average resident declined by 9.6 percent and 19.1 percent, respectively (Kneebone and Holmes 2015). In the context of Washington DC, spatial mismatch is often described along a east-west division along the Anacostia River (Chung 2015).

### Background and motivation:

This proposed analysis of the Purple Line is  grounded in previous studies of public transit projects in other geographies. Fan et al. (2012) examined the impact of a new light-rail line in the Minneapolis metropolitan area on access to jobs for high-, medium-, and low-wage workers; they found positive effects on job accessibility for all cohorts. Holzer et al. (2003) leveraged the construction of a new heavy-rail system in the San Francisco Bay Area to conduct a survey of firms; they found increased hiring of residents near new stations.

While many studies use administrative data to draw conclusions on new metro stations' impacts, our proposed analysis would include both administrative and longitudinal survey data. The primary motivation for conducting  surveys as opposed is that we can collect unique data points during pre- and post-treatment periods. After-the-fact analysis of administrative data limits possible lines of inquiry. The delayed construction and opening of the Purple Line in 2026 represents a unique opportunity for a natural experiment. Holzer et al.'s (2003) analysis of new metro line in the San Francisco Bay Area offers a useful model for pre- and post-treatment surveys. Holzer et al (2003) deployed surveys of firms before and after the opening of a new heavy-rail line to examine their propensity to hire minority workers residing near new stations. A similar analysis of the DC area labor market offers an opportunity to address previous limitations.

## Intervention
### Market failure:

Spatial mismatch is an issue that labor market studies have yet to resolve. This market failure occurs when there are inequal opportunities for employment based on where an individual resides. Even when access to public transportation has no effect on the rate at which a company hires minority applications, spatial mismatch implies that companies that want to avoid hiring certain or all minority applicants may choose to establish their firms in publicly inaccessible locations. The intervention (described below) capitalizes on a public-private partnership established by the state of Maryland.


### Theory of change:

The Purple Line project employs a direction small-scale intervention: a public-private partnership with the Maryland Department of Transportation and Purple Line Transit Partners, LLC. Through the partnership, the state of Maryland seeks to correct severe traffic congestion in the Beltway (the highway that encircles the District of Columbia) while improving mobility for households who are dependent on public transportation. Current projections estimate that roughly 17,000 daily auto trips will be eliminated while reducing travel times by nearly 40%. Our model tests whether expanding access to public transportation for low-income households who tend to live farther away from job opportunities not only improves efficiency of the overall public transportation system, but also improves socio-economic equity and advancement as well as reduce negative externalities. Testable implications of results include proximity to transit stops on unemployment rates and employment patterns. In the DMV, it is possible that the additional transit stops have no effect on the mobility and thus access to employment opportunities of any group of individuals.

### Relevance:
Beyond understanding the local impact of expanding transit-stops on accessibility to employment opportunities for low-income households and minority households, this project will contribute a deeper contextual analysis within the field of urban planning to the growing discussion of spatial mismatch as well as insight into social policies at large to invest and support community-based job development and accessible, well-developed public transportation systems. Several studies have suggested that investing in and increasing public transportation mobility is the most feasible and efficient short term fix for these issues. What we learn in this project may serve to inform discussions of land use surrounding zoning and housing, which are closely linked to transportation and employment issues as well.


## Measurement
### Design:
We propose a difference-in-difference model that refines and builds on Holzer et al's (2003) study of new metro lines in the Bay Area. We prefer this model type for our study, because we identified a policy that was enacted, and we would like to design a study that would be able to measure the impact of that policy over time. We are able to utilize a difference-in-differences model, because we can reasonably assume that trends in employer hiring practices in the DMV area would be similar both before and after extension of the Purple Line into the suburbs of northern Virginia. The treatment groups (including pre and post policy implementation) will comprise of firms having recently hired Black employees both before and after the Purple Line extension project was completed. The control groups will consist of firms having recently hired non-Black employees both before and after the Purple Line project is completed. The overall change in the comparison group (non-Black workers being hired before and after policy implementation) subtracted from the change in the target group (hired Black workers before and after the opening of the Purple Line) will be our difference estimate.


### Data:
We would conduct a longitudinal two-wave survey of firms in the Maryland suburbs surrounding planned Purple Line metro stations. We would additionally identify three employer size categories, including small, medium, and large firms and organizations. The first-wave survey would have been conducted in the two weeks prior to completion of the Purple Line extension project. The second-wave survey of firms would be conducted approximately one year following the project completion. The research design additionally relies upon survey interviews (conducted ideally via email) with a hiring individual or manager with each establishment identified. The main information collected during the two-wave surveys would ideally be focused on the race of the most recent hires with each interviewed firm. The difference estimate (as described above) would be ideally calculated in Stata.

In addition to survey data, we would access recent Public-Use Microdata Sample (PUMS) data to examine variables related to commuting, employment, residence, and measures of socioeconomic well-being, both before and after the construction of the Purple Line.


### Complications:
Employer response rates to surveys inquiring about hiring practices and outcomes may likely be very low, even if the surveys were to be conducted via email, rather than telephone or in-person surveys. The main objective would to be to focus on collecting information from each interviewed hiring manager of the organization's most recent hire. Perhaps a more egregious complication would be that we are unable to invent a time machine and interview firms prior to the completion of the Purple Line metro  project. If data already exists on the race of the more recent hires with firms near the Purple Line stations prior to the extension, we could perhaps rely upon this data. Another possible solution might be that we could inquire the hiring managers of each interviewed organization to review their hiring histories and ask them to report the racial makeup of the recently-hired employees approximately two weeks before the Purple Line extension end date.


### Bibliography
https://www.nber.org/papers/w20066


https://www.brookings.edu/research/the-growing-distance-between-people-and-jobs-in-metropolitan-america/


https://ggwash.org/view/37817/jobs-are-clustering-in-parts-of-the-region-but-the-east-is-falling-behind


https://www.jtlu.org/index.php/jtlu/article/view/240


https://www.jstor.org/stable/3326034
