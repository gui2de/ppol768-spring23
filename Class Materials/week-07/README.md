# Week 7 Announcement : Github repo cleanup and process simplification

## Github repo cleanup

During Spring Break, we will merge all the branches that are currently pending and haven't been merged, delete all the remote branches of the repo, and clean up the repo so it is easier to navigate.

If you have any local work on your machine that you haven't pushed to the remote repo yet, please make sure it is pushed to the remote (ie github) repo by **Tuesday, March 7th**. Once we have merged and deleted all the branches on the remote repo, we will notify you so you can also delete your branches locally on your machine.

Moving forward, we will keep up this cleaning process weekly to avoid cluttering the github repo. Concretely, every Tuesday before class, we will be merging your branches into main (even if the review hasn't been completed) and deleting from the remote repo any branch from closed out assignments. For example, your survey assignment is due on March 13th, and your peer review of someone else's survey is due on March 20th, so on March 21st, we will be merging and deleting all branches related to survey submissions if any are still pending.

## Reminder : process to submit your weekly individual assignments

Each week, you will do the following steps to submit your assignment in the class repo.
- Pull the main branch of the class repository to your local repo using GitKraken to make sure you are working off the latest version published on GitHub.
- Create and check out a branch for this week's asssignments called `w07-netid` (replace "netid" by your netid) using GitKraken. The branch should be pointing to the latest commit.
- Navigate in your file browser (ie, Finder or Files Explorer) to the repository, and open the folder with your name inside the "Individual Assignments" directory.
- Create a `week-07` folder inside your folder in the "Individual Assignments" directory.
- In your `week-07` folder, create and save all your assignment files (dofiles, markdown files, etc).
- Stage your changes into commits, and push your branch to the GitHub remote using GitKraken (it will prompt you to create the branch in the remote repo)
- Open a Pull Request (PR) to the `main` branch using the online GitHub interface. Assign someone at random from the group to review your request by tagging the class group (@ppol768-spring23) under the Reviewers' box on the right.
- When you are assigned someone else's assignment to review, you should check-out their branch on your own local repo, so you can run their dofiles and perform a complete review by running their code locally, then leaving comments on the PR interface on Github.
- Once a PR has been reviewed and approved (the week after the assignment is due), you will be able to merge it into the main branch of the repository. Prior to merging, you are welcome to make more changes (locally) and commit/push them to the same branch (to the remote), in order to take into account the reviewers' comments. Once you are satisfied with your submission, merge your branch onto main and delete your branches, both on the remote and your local repo.

A few notes on this process :
- We are changing the initials to netids to avoid duplication
- If you have pushed your branch and opened the pull request and you then make more changes to your work, you can push new commits to the same branch and they will get added to the same pull request. You do not need to create a branch everytime you work on github; only when you start a new feature (ie a new assignment), in order to isolate the changes you make related to that assignment, so they are easy to review on their own.
- Remember to delete your branch on github AND on your local repo after you have merged your branch into main 

# Week 7 Homework Assignments

This summarizes the assignments due on Monday March 13th, upon returning from Spring Break. We specify detailed steps for each assignment below, as well as updated github submission instructions.

## Assignment 1 : Group Project Concept Note

This is an update to your original group project submission. The goal is to expand on your pitch and go to a 7-10 pages document presenting a more fully fledged version of your research proposal. Compared to your original pitch, the concept note will
1. Address the feedback we have provided
1. Expand on existing sections with more specifics
1. Add sections to build towards the final submission, which will look like a PAP

Real life examples of what the final submission of the group project is are available [here](https://github.com/gui2de/ppol768-spring23/blob/0f07d94d58514f81598f478eb30c45c4d56eccc2/Group%20Projects/examples/PAP%20Rwanda%20Cash%20Benchmarking%20-%20Stage%201.pdf) or [here](https://github.com/gui2de/ppol768-spring23/blob/0f07d94d58514f81598f478eb30c45c4d56eccc2/Group%20Projects/examples/PAP_Final_Caria%20et%20alpdf.pdf). This concept note is NOT the final submission, so it will not be as detailed, nor as complicated, but you can consider it as a draft of that final document, and follow a similar structure. Do not worry yet about the sections on statistical analysis and power calculations, which we will cover in lectures in the second half of class. However, the sections on motivation, intervention or research design, outcomes and mechanisms, and data collection should be well fleshed out.

As always, you can book our office hour slots and/or message us to talk through your project or other work.

You will submit it through Github, as a new document inside your project folder. You are welcome to submit either another .MD file called ConceptNote, or a .pdf file. You will submit your group assignment via a dedicated branch and pull request, which one of you will create. You are welcome to use that branch to work together on the document remotely within your group (ie once one of you has created the branch for your group project, all of you can check it out locally and work on it), or work outside of github and simply upload the final document to the class repo. Because there is no peer review requested for the group project, you will not be assigning anyone for review when creating the pull request.

## Assignment 2 : Individual Survey Coding

You will be coding your own survey on SurveyCTO. We are not prescribing the exact questions you need to be asking with your survey, but some types of modules you need to include, which are all modules covered in the example survey we took and coded together in class. You will code your survey using Google Sheets, upload and test it on SurveyCTO using the log in information below, and have someone else from your project group review your survey.

### Step 1 : Create a Google Sheets Template for SurveyCTO

1. Log into gui2de's SurveyCTO server (https://gui2de.surveycto.com/) with the login information shared via email to the class.
1. Navigate to the PPOL 768 group on the Design tab
1. Create a new form (give it a unique name and ID) and select "Download to Google Drive"
1. Open the file you just created in your Google Drive
1. Add a Cover tab and a Changes Log tab to the form

### Step 2 : Code your own survey

Using the Google Sheets template, you will code a survey for SurveyCTO containing the following things :
- One identification module
- One demographics module
- One module that involves listing things (roster of people, of classes, of habits etc) with a repeat group
- One module that involves quantifying something (time spent, income received, etc) including calculated fields enforcing checks
- At least one question with a likert scale (agree/disagree or true/false scale)
- At least one question pulling from an external dataset (it can be the same external dataset as the class survey, or another one), using either search() or pulldata() commands

We are not prescribing the exact questions your survey should contain. You should think of a specific target population for your survey, and the questions should be coherent for that population. It can, but doesn't have to, be related to your group project topic. You may find it convenient to make these related, as it can help you think through your project topic as well.

### Step 3 : Upload it to SurveyCTO and test it

Using the login information above, upload your survey to SurveyCTO and use the error prompts while uploading the survey to fix any bugs, and the testing interface to test your code.

Note that creating the survey (step 1 above) doesn't actually upload it to SurveyCTO, it simply creates the template for you to download. You need to upload it the first time by going into the PPOL 768 group on SurveyCTO, clicking "Upload Form Definition" and selecting your survey from Google Drive. After the survey has been uploaded once, you simply update it by clicking the Upload button next to the survey name (Upload Revised Form), and it will overwrite the previous form definition for the new one you link from Google Drive.

### Step 4: Submit your work on Github for peer review

As per usual, pull the latest version of the main branch and create your own branch to submit this week's assignment.

For this assignment, you will simply submit a markdown file (.MD) containing the links to your survey. Under your own individual folder of the class repo, create a .MD document named appropriately, and in that markdown file, add two links:
- A link to your survey form in google drive (make sure in the settings of the sheet on google you have allowed anyone to comment on it)
- A link to your survey fill-out link for someone to fill out the survey. To find that link, go to the 2. Collect tab on SurveyCTO, navigate to your form and click "Share".

Feel free to add any other relevant context on your survey in that markdown file if you deem it relevant.

Create a Pull Request to merge this week's assignment into the main branch, and assign for review the next person within your project group as per alphabetical order (the alphabetical list of students per group is under the \_Group Projects folder of the class repo). Example with group 1: Sylvia will review Shaily's, Neel will review Sylvia's, and Shaily will review Neel.

### Step 5 : Review someone else's survey (due the following week only)

Once someone asks your review on a survey, you should
1. Use the fill-out link for the survey and submit at least one mock response to the survey, using this opportunity to test the survey coding. You may need to log in using the credentials above to fill out the survey.
1. Review the code in the google sheet and make any relevant comments/feedback via the github pull request.

## Assignment 3 : Mid-term Self-Evaluation

The third assignment is your midterm self evaluation. The template for it is available [here](https://docs.google.com/document/d/1tWC3z3pbHoNAn_octc_Edj3W4f7DinQd6sLhLbjo-Lw/edit?usp=sharing).

You will submit it using this Box link, following the naming convention : LASTNAME-MIDTERM. (replace "LASTNAME" with your own last name)

Please download the template and fill it out by giving yourself a rating on each dimension, and supporting it with examples/justification. You can be as detailed or as concise as necessary for the argumentation.

We will then send you a link for one-on-one 20-min check-ins after Spring Break with one of us, which we will use to discuss your self evaluation, your performance in this course, as well as any other feedback you may have on the course and your progress in it.
