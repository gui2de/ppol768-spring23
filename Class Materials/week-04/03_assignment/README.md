# Week 4

This week's (due 02/13) assignments are.

## Reminder : Github Instructions for Assignment Submissions

Each week, you will do the following steps to submit your assignment in the class repo.
- Pull the main branch of the class repository to your local repo using GitKraken to make sure you are working off the latest version published on GitHub.
- Create and check out a branch for this week's asssignments called `w04-initials` (replace "initials" by your initials) using GitKraken. The branch should be pointing to the latest commit.
- Navigate in your file browser (ie, Finder or Files Explorer) to the repository, and open the folder with your name inside the "Individual Assignments" directory.
- Create a `week-04` folder inside your folder in the "Individual Assignments" directory.
- In your `week-04` folder, create and save all your assignment files (dofiles, markdown files, etc).
- Stage your changes into commits, and push your branch to the GitHub remote using GitKraken (it will prompt you to create the branch in the remote repo)
- Open a Pull Request (PR) to the `main` branch using the online GitHub interface. Assign someone at random from the group to review your request by tagging the class group (@ppol768-spring23) under the Reviewers' box on the right.
- When you are assigned someone else's assignment to review, you should check-out their branch on your own local repo, so you can run their dofiles and perform a complete review by running their code locally, then leaving comments on the PR interface on Github.
- Once a PR has been reviewed and approved (the week after the assignment is due), you will be able to merge it into the main branch of the repository. Prior to merging, you are welcome to make more changes (locally) and commit/push them to the same branch (to the remote), in order to take into account the reviewers' comments. Once you are satisfied with your submission, merge your branch onto main and delete your branches, both on the remote and your local repo.

## Q1 : Crop Insurance in Kenya

You are working on a crop insurance project in Kenya. For each household, we have the following information: village name, pixel and payout status.

a)	Payout variable should be consistent within a pixel, confirm if that is the case. Create a new dummy variable (`pixel_consistent`), this variable =1 if payout variable isn’t consistent within that pixel (i.e. =0 when all the payouts are exactly the same, =1 if there is even a single different payout in the pixel)
b)	Usually the households in a particular village are within the same pixel but it is possible that some villages are in multiple pixels (boundary cases). Create a new dummy variable (`pixel_village`), =0 for the entire village when all the households from the village are within a particular pixel, =1 if households from a particular village are in more than 1 pixel. Hint: This variable is at village level.
c)	For this experiment, it is only an issue if villages are in different pixels AND have different payout status. For this purpose, divide the households in the following three categories:
I.	Villages that are entirely in a particular pixel. (==1)
II.	Villages that are in different pixels AND have same payout status (Create a list of all hhids in such villages) (==2)
III.	Villages that are in different pixels AND have different payout status (==3)
These 3 categories are mutually exclusive AND exhaustive i.e. every single observation should fall in one of the 3 categories.

## Q2 : National IDs in Pakistan

 We have the information of adults that have computerized national ID card in the following pdf: [Pakistan_district_table21.pdf](01_data/q2_Pakistan_district_table21.pdf). This pdf has 135 tables (one for each district.) We extracted data through an OCR software but unfortunately it wasn’t very accurate. We need to extract column 2-13 from the first row (“18 and above”) from each table. Create a dataset where each row contains information for a particular district. The hint do file contains the code to loop through each sheet, you need to find a way to align the columns correctly.

 ## Q3 : Faculty Funding Proposals

Faculty members submitted 128 proposals for funding opportunities. Unfortunately, we only have enough funds for 50 grants. Each proposal was assigned to randomly selected students in PPOL 768 where they gave a score between 1 (lowest) and 5 (highest). Each student reviewed 24 proposals and assigned a score. We think it will be better if we normalize the score wrt each reviewer before calculating the average score. Add the following columns 1) stand_r1_score 2) stand_r2_score 3) stand_r3_score 4) average_stand_score 5) rank (highest score =>1, lowest => 128)

## Q4 : Student Data from Tanzania

Q4: This task involves string cleaning and data wrangling. We scrapped student data for a school from [Tanzania's government website](https://onlinesys.necta.go.tz/results/2021/psle/results/shl_ps0101114.htm). Unfortunately, the formatting of the data is a mess. Your task is to create a student level dataset with the following variables: schoolcode, cand_id, gender, prem_number, name, grade variables for: Kiswahili, English, maarifa, hisabati, science, uraia, average.
