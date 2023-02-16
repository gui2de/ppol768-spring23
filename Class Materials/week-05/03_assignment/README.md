Week 5

This week's (due 02/20) assignments are.

## Reminder : Github Instructions for Assignment Submissions

Each week, you will do the following steps to submit your assignment in the class repo.
- Pull the main branch of the class repository to your local repo using GitKraken to make sure you are working off the latest version published on GitHub.
- Create and check out a branch for this week's asssignments called `w05-initials` (replace "initials" by your initials) using GitKraken. The branch should be pointing to the latest commit.
- Navigate in your file browser (ie, Finder or Files Explorer) to the repository, and open the folder with your name inside the "Individual Assignments" directory.
- Create a `week-05` folder inside your folder in the "Individual Assignments" directory.
- In your `week-05` folder, create and save all your assignment files (dofiles, markdown files, etc).
- Stage your changes into commits, and push your branch to the GitHub remote using GitKraken (it will prompt you to create the branch in the remote repo)
- Open a Pull Request (PR) to the `main` branch using the online GitHub interface. Assign someone at random from the group to review your request by tagging the class group (@ppol768-spring23) under the Reviewers' box on the right.
- When you are assigned someone else's assignment to review, you should check-out their branch on your own local repo, so you can run their dofiles and perform a complete review by running their code locally, then leaving comments on the PR interface on Github.
- Once a PR has been reviewed and approved (the week after the assignment is due), you will be able to merge it into the main branch of the repository. Prior to merging, you are welcome to make more changes (locally) and commit/push them to the same branch (to the remote), in order to take into account the reviewers' comments. Once you are satisfied with your submission, merge your branch onto main and delete your branches, both on the remote and your local repo.

## Q1 : Tanzania Student Data

This builds on Q4 of week 4 assignment. We downloaded the PSLE data of students of 138 schools in Arusha District in Tanzania (previously had data of only 1 school) You can build on your code from week 4 assignment to create a student level dataset for these 138 schools.

## Q2 : Côte d'Ivoire Population Density

We have household survey data and population density data of Côte d'Ivoire. Merge departmente-level density data from the excel sheet (CIV_populationdensity.xlsx) into the household data (CIV_Section_O.dta) i.e. add population density column to the CIV_Section_0 dataset.

## Q3 : Enumerator Assignment based on GPS
We have the GPS coordinates for 111 households from a particular village. You are a field manager and your job is to assign these households to 19 enumerators (~6 surveys per enumerator per day) in such a way that each enumerator is assigned 6 households that are close to each other. Manually assigning them for each village will take you a lot of time. Your job is to write an algorithm that would auto assign each household (i.e. add a column and assign it a value 1-19 which can be used as enumerator ID). Note: Your code should still work if I run it on data from another village.

## Q4 : 2010 Tanzania Election Data cleaning

2010 election data (Tz_election_2010_raw.xlsx) from Tanzania is not usable in its current form. You have to create a dataset in the wide form, where each row is a unique ward and votes received by each party are given in separate columns. You can check the following dta file as a template for your output: Tz_elec_template. Your objective is to clean the dataset in such a way that it resembles the format of the template dataset.


## Q5 : Tanzania Election data Merging

Between 2010 and 2015, the number of wards in Tanzania went from 3,333 to 3,944. This happened by dividing existing ward into 2 (or in some cases more) new wards. You have to create a dataset where each row is a 2015 ward matched with the corresponding parent ward from 2010. It’s a trivial task to match wards that weren’t divided, but it’s impossible to match wards that were divided without additional information. Thankfully, we had access to shapefiles from 2012 and 2017. We used ArcGIS to create a new dataset that tells us the percentage area of 2015 ward that overlaps a 2010 ward. You can use information from this dataset to match wards that were divided.  
