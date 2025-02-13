## Bikeshare HFCs ##

This code runs through recorded trip data from Capital Bikeshare (CaBi) and identifies potentially wrong datapoints and datapoints with missing information. Capital Bikeshare is a public private partnership program where the District of Columbia and surrounding jurisdictions have collaborated with the Lyft to provide bikes for residents to ride at modest costs. Capital Bikeshare stations can be found as far south as Alexandria, VA and as far North as Rockville, MD. Residents and visitors can pay by the ride, buy day passes, or purchase annual memberships. Our intention is to flag potentially lost/stolen/missing bikes, docks that are not registering properly and unusual rides. 

### HFC 1: Missing information ###
In delivering bikes to Capital area residents, CaBi tracks some information about each bike trip. For a given traditional bike trip, a user will unlock a bike from one station, ride to their destination and dock at a new station. For a given e-assist bike ride, a user can either unlock a bike from a dock, or from a location where a bike has been left by a previous user. The start and end time are recorded for each ride, as well as the start station and end station. This data can help CaBi to understand travel patterns, and better stock stations with bikes when demand is likely. 

To be able to rely on this data, this HFC is a simple check for missing information. This check loops through important variables to make sure each ride is being documented.


### HFC 2: Lost/stolen/improperly docked bikes ###
Of course, CaBi has an interest in keeping bikes available for all users. Sometimes, very long or very short  ride-times can indicate a lost or stolen bike, a bike that has mechanical issues, or a dock that has mechanical issues. Bike rides are most affordable for non members when less than 30 minutes in duration and most affordable for members when less than 45 minutes. Since it is usually costly to ride much beyond these thresholds, we set our thresholds for an unusuually long rie a bit higher at 1.25 hours for non-members and 1.5 hours for members. This HFC checks to see if a bike has been out for an unusually long period of time and flags that bike for maintenance.

Data used here are made available by Capital Bikeshare under their Data License Agreement that states "Bikeshare hereby grants to you a non-exclusive, royalty-free, limited, perpetual license to access, reproduce, analyze, copy, modify, distribute in your product or service and use the Data for any lawful purpose ("License")." To run this code, please access data from the capital bikeshare index of data [here](https://s3.amazonaws.com/capitalbikeshare-data/index.html). This code was designed for Quarter 1 of 2017. Data formats may have changed before or after that point in time. 


