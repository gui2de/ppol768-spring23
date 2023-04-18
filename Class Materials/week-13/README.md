# Week 13 Homework Assignment

## Survey Update 

For the last individual assignment of this class, you will be updating your surveycto survey by adding the following features to it. This assignment is due on Monday May 1.

- Address the feedback from the peer review and instructor review from your week-07 submission
- Add a "duplicate" check to enforce uniqueness of survey responses. This will require having a question in the survey that constitutes a unique identifier of responses (eg. email ID), a server dataset that your survey will be publishing into, a calculate field that will pull from that server dataset, and a note whose relevance condition will be using this calculate field.
- Add a "sensitive" module implementing a list experiment : you will need a calculate field drawing a random number and taking a control or treatment value from it, and you can either use a choice filter or a relevance condition (repeating the question) to implement the experiment. The sensitive module should make sense in the context of the survey you are asking. It doesn't have to be "conventionally" sensitive, but it has to tackle a question you may have good reasons to believe asking directly would not lead to appropriate answers.
- Download the stata command [iefieldkit](https://dimewiki.worldbank.org/Iefieldkit) from DIME and run ietestform on your survey form. Implement all the changes suggested by the ietestform output, and add the ietestform output to your submission folder on github.

In the process, remember to upload the survey to surveycto (you will update your current form, and not create a new form) and test it. You will probably need to submit some mock submissions to test the duplicate check.

To submit this assignment, you will, similar to week 07, simply submit in your week-13 subfolder a .md file containing your two survey links (links to your google sheet and link to surveycto to fill out your survey) as well as any relevant context about your survey and in particular your additions to it. You will also add to your subfolder the output of the ietestform command you ran on your survey form.

As this is the final assignment for this class, there is no peer review for it. Do not tag anyone on the pull request.

# Final Class Assignments

## Final Group Presentations : slides due by Monday 04/24

As mentioned in our [class announcement](https://github.com/gui2de/ppol768-spring23/discussions/343), all slides will be due by Monday 04/24 (or, more exactly, prior to the class start on 04/25). Groups will be presenting on 04/25, 04/27 and 05/02. We will be drawing randomly, on the day of the presentations, which groups present that day. For this reason, everybody needs to have their slides ready at the same time - prior to the first presentation day - and no one will be able to make edits to their slides after that day. The material that we will use as support for your presentation is whatever you submitted on 04/25.

Groups will present on 04/25, 04/27 and 05/02 for 20-25min including Q&A with instructors.  

You will be able to make edits to your final group project after presentations, until Monday 05/08 when they are due.

## Pending Individual Assignments : due by Monday 05/01

The last individual assignment for this class (survey v2) is due on Monday 05/01, and so are all other individual assignments for the class. If you have any pending individual submissions or updates you are meaning to do to your old individual assignments, make sure they are in by 05/01 so we are able to take them into account in the final grade.

## Final Group Projects : due by Monday 05/08

This is the final submission for your group project. It will incorporate feedback you got from instructors following the concept note and the presentation.

Real life examples of what the final submission of the group project is are available [here](https://github.com/gui2de/ppol768-spring23/blob/0f07d94d58514f81598f478eb30c45c4d56eccc2/Group%20Projects/examples/PAP%20Rwanda%20Cash%20Benchmarking%20-%20Stage%201.pdf) or [here](https://github.com/gui2de/ppol768-spring23/blob/0f07d94d58514f81598f478eb30c45c4d56eccc2/Group%20Projects/examples/PAP_Final_Caria%20et%20alpdf.pdf).

You will submit it through Github, as a new document inside your project folder. You are welcome to submit either another .MD file called FinalProject, or a .pdf file. You will submit your group assignment via a dedicated branch and pull request, which one of you will create. You are welcome to use that branch to work together on the document remotely within your group (ie once one of you has created the branch for your group project, all of you can check it out locally and work on it), or work outside of github and simply upload the final document to the class repo. Because there is no peer review requested for the group project, you will not be assigning anyone for review when creating the pull request.

## Final Individual Self-Evaluation

The final assignment is your self evaluation. The template for it is available [here](https://docs.google.com/document/d/1tWC3z3pbHoNAn_octc_Edj3W4f7DinQd6sLhLbjo-Lw/edit?usp=sharing).

Submit this assignment using the Box submission link: [SUBMIT](https://georgetown.app.box.com/f/e8b46836b7304c81b1461c8756615f8f). Please follow the naming convention LASTNAME-FINAL (replace "LASTNAME" with your own last name) for the file name.

Please download the template and fill it out by giving yourself a rating on each dimension, and supporting it with examples/justification. You can be as detailed or as concise as necessary for the argumentation.

# Github Process Reminder

Each week, you will do the following steps to submit your assignment in the class repo.
- Pull the `instructions` branch of the class repository to your local repo using GitKraken to make sure you are working off the latest version published on GitHub.
- Create and check out a branch for this week's asssignments called `w13-netid` (replace "netid" by your netid) using GitKraken. The branch should be pointing to the latest commit, which will be named something like __"Start week-13 assignment here"__
- Navigate in your file browser (ie, Finder or Files Explorer) to the repository, and open the folder with your name inside the "Individual Assignments" directory.
- Create a `week-13` folder inside your folder in the "Individual Assignments" directory.
- In your `week-13` folder, create and save all your assignment files (dofiles, markdown files, etc).
- Stage your changes into commits, and push your branch to the GitHub remote using GitKraken (it will prompt you to create the branch in the remote repo)
- Open a Pull Request (PR) to the `main` branch using the online GitHub interface. Assign someone at random from the group to review your request by tagging the class group (@ppol768-spring23) under the Reviewers' box on the right.
- When you are assigned someone else's assignment to review, you should check-out their branch on your own local repo, so you can run their dofiles and perform a complete review by running their code locally, then leaving comments on the PR interface on Github.
- Once a PR has been reviewed and approved (the week after the assignment is due), you will be able to merge it into the main branch of the repository. Prior to merging, you are welcome to make more changes (locally) and commit/push them to the same branch (to the remote), in order to take into account the reviewers' comments. Once you are satisfied with your submission, merge your branch onto main and delete your branches, both on the remote and your local repo.
