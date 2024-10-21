# Contributing Guidelines 
## Branching
You always create a branch from an existing branch. Typically, you might create a new branch from the default branch of your repository. You can then work on this new branch in isolation from changes that other people are making to the repository.

Once you're satisfied with your work, you can open a pull request to merge the changes in the current branch (the head branch) into another branch (the base branch). After a pull request has been merged, or closed, the head branch can be deleted as it is no longer needed.

## Pull Requests

If your pull request consists of changes to multiple files, provide guidance to reviewers about the order in which to review the files. Recommend where to start and how to proceed with the review.
Once you've created a pull request, you can push commits from your topic branch to add them to your existing pull request. These commits will appear in chronological order within your pull request.

Other contributors can review your proposed changes, add review comments, contribute to the pull request discussion, and even add commits to the pull request. By default, in public repositories, any user can submit reviews that approve or request changes to a pull request. Organization owners and repository admins can limit who is able to give approving pull request reviews or request changes.

After you're happy with the proposed changes, the PR can be merged from the feature branch into the base branch that is specified in the PR.

You can link a pull request to an issue to show that a fix is in progress and to automatically close the issue when someone merges the pull request. For more information, see "[Linking a pull request to an issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue)."
#### Best Practices for creating pull requests
When creating a pull request, follow a few best practices for a smoother review process. 
##### Write small PRs
Aim to create small, focused pull requests that fulfill a single purpose. Smaller pull requests are easier and faster to review and merge, leave less room to introduce bugs, and provide a clearer history of changes.
##### Review your own pull request first
Test your own pull request before submitting it. This will allow you to catch errors or typos that you may have missed, before others start reviewing. Make sure there are no merge conflicts with the branch your are sending the pull request to.
##### Provide context and guidance
Write clear titles and descriptions for your pull requests so that reviewers can quickly understand what the pull request does. In the pull request body, include:
- the purpose of the pull request
- an overview of what changed
- links to any additional context such as tracking issues or previous conversations

You can follow the template that is provided in our repo.

### Draft pull requests
When you create a pull request, you can choose to create a pull request that is ready for review or a draft pull request. Draft pull requests cannot be merged, and code owners are not automatically requested to review draft pull requests.

When you're ready to get feedback on your pull request, you can mark your draft pull request as ready for review. Marking a pull request as ready for review will request reviews from any code owners. You can convert a pull request to a draft at any time.

### Handling merge conflict
Git can often resolve differences between branches and merge them automatically. Usually, the changes are on different lines, or even in different files, which makes the merge simple for computers to understand. However, sometimes there are competing changes that Git can't resolve without your help. Often, merge conflicts happen when people make different changes to the same line of the same file, or when one person edits a file and another person deletes the same file.

You must resolve all merge conflicts before you can merge a pull request on GitHub. If you have a merge conflict between the compare branch and base branch in your pull request, you can view a list of the files with conflicting changes above the Merge pull request button. The Merge pull request button is deactivated until you've resolved all conflicts between the compare branch and base branch.

To resolve a merge conflict, you must manually edit the conflicted file to select the changes that you want to keep in the final merge. There are a couple of different ways to resolve a merge conflict:
- If your merge conflict is caused by competing line changes, such as when people make different changes to the same line of the same file on different branches in your Git repository, you can resolve it on GitHub using the conflict editor. For more information, see "[Resolving a merge conflict on GitHub](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/addressing-merge-conflicts/resolving-a-merge-conflict-on-github)."
- For all other types of merge conflicts, you must resolve the merge conflict in a local clone of the repository and push the change to your branch on GitHub.  For more information, see "[Resolving a merge conflict using the command line.](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/addressing-merge-conflicts/resolving-a-merge-conflict-using-the-command-line)"
### Pull Request Reviews
After a pull request is opened, anyone with read access can review and comment on the changes it proposes. You can also suggest specific changes to lines of code, which the author can apply directly from the pull request. For more information, see "[Reviewing proposed changes in a pull request.](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/reviewing-proposed-changes-in-a-pull-request)"

Reviews allow for discussion of proposed changes and help ensure that the changes meet the repository's contributing guidelines and other quality standards.

You can re-request a review, for example, after you've made substantial changes to your pull request.

You can comment on a pull request's Conversation tab to leave general comments, questions, or props. You can also suggest changes that the author of the pull request can apply directly from your comment.

You can also comment on specific files or sections of a file in a pull request's Files changed tab in the form of individual line or file comments, or as part of a pull request review. Adding line or file comments is a great way to discuss questions about implementation or provide feedback to the author.

#### Applying suggested changes
Other people can suggest specific changes to your pull request. You can apply these suggested changes directly in a pull request if you have write access to the repository. If the pull request was created from a fork and the author allowed edits from maintainers, you can also apply suggested changes if you have write access to the upstream repository.

To quickly incorporate more than one suggested change into a single commit, you can also apply suggested changes as a batch. Applying one suggested change or a batch of suggested changes creates a single commit on the compare branch of the pull request.

Each person who suggested a change included in the commit will be a co-author of the commit. The person who applies the suggested changes will be a co-author and the committee of the commit.

For more information on pull requests, see “[Pull Requests](https://docs.github.com/en/pull-requests)”

### Commits
A helpful technique to use is to focus on the commit messages, using a heading and bullet points.

For the first line of the commit message use a short summary of all the changes (“feat: implement admin middleware”, “fix: update vulnerable package”, “chore: clean up codebase” you get it). Then add a list of bullet points, one for every file you changed.

Sometimes it makes sense to do 1 bullet point for multiple files (you changed a variable in 10 places, you abstracted code to a function and replaced its usage across the project, etc…). The key to the bullet points is to start with “CRUD”-based language: “- added ...,” “- revised ...,” “- removed ...” to indicate the action taken and then add the **WHY** in the explanation: “- added an aria-label attribute to the icon tag since a label wasn’t previously provided and we need to pass accessibility standards.” The why provides every person looking at the code from that moment on all the info they need to choose to refactor it, delete it, etc… in the future.

For more information on writing commit message, see “[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)”
## Issues Tracking

- When creating an issue, make sure to follow the provided issue template for structure and clarity.
- Always provide a concise yet descriptive title that captures the essence of the issue.
### Types of Issues
- **Feature Requests and Changes**: If you're suggesting a new feature or proposing changes to an existing one, ensure that your issue clearly outlines the expected behavior and the reasons behind the request. Use the **Feature/Change Request** template.
  
- **Bug Reports**: For bug-related issues, make sure to describe the problem in detail. Include the steps to reproduce, observed behavior, and expected behavior. Use the **Bug Report** template.

### Work Process and PR Mentions
- When you finish working on an issue, mention the issue number in your pull request (PR) to maintain traceability.
	- Example: `Fixes #123` or `Addresses #456`. This ensures that the issue is automatically linked to the work being done in the PR.

## File structure

### Organization of files and directories
The project is organized into different folders based on functionality and reusability:
- Files specific to the boolean reduction process that cannot be reused outside of this context are located in the `boolean-reduct` folder.
- Utility functions that are boolean reduction specific but can be reused within this context are found in the `boolean-reduct/rte-helpers.metta`.
- Utility functions that are specific to a certain file and aren't necessarily needed by any other file yet should be put within the same file. For example, helper functions that are specific to the `boolean-reduct/promote-common-constraints.metta` file are found in this same file. Whenever the functions defined here are needed by any other files in the `boolean-reduct`, they will be moved to the `boolean-reduct/rte-helpers.metta`.
- Corresponding tests for each folder are placed in a `tests` subdirectory within that same folder. For example, tests for boolean reduction are found in `boolean-reduct/tests`, while utility tests are in `utilities/tests`. 
- When creating a new file, its test should be defined in the appropriate folder. The name of the test file should start with the same name as the file it's testing and has an extension of `-test.metta`.
- Reusable code that can be applied across multiple use cases is placed in the `utilities` folder. These helpers mainly include `utilities/general-helpers.metta`.
### Creating new files
Whenever a new file is defined, it should follow our current project structure. Please adhere to the following rules:
- **Self-contained Functions**: The file should include all the unique functions it needs to operate. These functions should be specific to the code within that file.
- **Location for Boolean Reduction Files**: If the file contains Metta code that is specific to the boolean reduction process, place it in the `boolean-reduct` folder. For example: `boolean-reduct/<new-file>.metta`.
- **Reusable Functions** : If the file contains functions that can be reused:
	- **Within the context of boolean reduction**, move those functions to the `boolean-reduct/rte-helpers.metta` file.
	- **Regardless of the use case**, such functions should be placed in `utilities/general-helpers.metta`.

In short:
- Boolean reduction-specific files go in `boolean-reduct/`.
- Reusable functions should go in either `boolean-reduct/rte-helpers.metta` or `utilities/general-helpers.metta`, depending on the context.
- Any executable code should be found in the `*-test.metta` files only. The rest of the files should contain the definitions of functions.

## Code conventions
### Naming Conventions
 - Use `camelCase` for naming custom functions and variables.
 - Use `PascalCase` for defining custom types.
### Formatting rules
Since MeTTa lacks a flexible formatter, formatting is done as you write code. Some basic formatting conventions we use for MeTTa include:
- **Function calls**:
    - If the parameters are short or few, keep the function call on a single line.
    - If the parameters are long or numerous, the function name should stick with the 
      left-most bracket, and the parameters should be placed on the next lines with 
      increased indentation. Example:
	```scheme
	;; Example function with short parameter

	;; Example function with long parameters
    (foo 
	    (and (== $x $y) (< $x 100))
		(X is valid parameter)
		(X isn't valid parameter)
    )

	;; Example function with many parameters
	(let* 
		(
			($x (someFunction1 ...))
			($y (someFunction2 ...))
			($z (someFunction3 ...))
		) 
		($x $y $z)
	)
	```
	- Whenever calling the `if` function, the function call should be a one line if the `$then` and `$else` cases are simple. But if either one of them is complex, the function name and the condition should be on the same line as the opening bracket and  the rest of the parameters should be on the next line with the same level of indentation as the condition. Example:
	```scheme
	;; Calling if with simple $then and $else condtions
	(if (== $x 1) True False)
	
	;; Calling if with complex $then and $else condtions
	(if (== $x 1)
		True
		(let* 
			(
				($x' (> $x 0))
				($result (< $x 10))
			)
			(and $x' $result)
		)
	)
	```

  - **Multi-line functions**: The closing bracket of a function should match the indentation level of its opening bracket.
  - **Indentation**: Increase indentation level for nested parameters or function calls for better readability.
### Function Definitions
- When creating multiple definition of a function, don't add empty lines between the definitions 
  unless the definitions are complex. For complex multi-line definitions, add a single line 
  between them for clarity.
- No empty lines should exist between a function and its type signature or its documentation.
- When writing complex function definition, the name of the function and it's parameters should be on the same line and the rest of the function definition should start on a new line with the same level of indentation as the function name.
Example:
```scheme
;; Example function that does nothing with simple definitions.
(: foo (-> Atom Atom))
(= (foo $x) ($x))
(= (foo $x $x) ($x))
(= (foo $x $y) ($x $y))
(= (foo $x $y $z) ($x $y $z))

;; Example function with complex definitions. 
(: foo' (-> Atom Atom))
(= (foo $x) 
   (if (...)
	   (...)
	   (...)
   )
)

(= (foo $x $y)
   (let $bar (if (== $x $y) (...) (...)))
)
```

### Commenting guidelines
- Always use double semicolons (`;;`) for comments instead of a single semicolon (`;`) to maintain consistency.

## Documentation standards
- Every new function should be documented using comments right before its definition.
- Comments should be sufficient to describe the function's purpose and how it works at a high level. _A comment for a function should be enough to give a high level description of what the function purpose is or what it tries to achieve without looking into the code._
- Include examples in the comments if necessary.
- It is recommended to comment every function, no matter how small it seems.

## Git flow

Git Flow is a branching strategy for Git that defines a structured workflow for managing features, releases, and bug fixes in software development.

Here, the workflow we are following will be described in depth. This workflow will be followed for collaborating on this project.

### Branching
#### Main branches
There are two main branches with indefinite lifetime. These are:
- `main` branch
- `dev` branch

On the `main` branch, the head always reflects the most complete state of the software. (A software that is production ready).
Each time changes are merged back to this branch, it's by definition a new release (version). 

On the `dev` branch, the head always points to the latest development changes for the next release. 
Whenever the source code in the `dev` branch reaches a stable state, it is merged into `main`.
#### Supporting branches
There are other branches that are used for ease of feature trying, fixing bugs or preparing production releases. 

These branches have limited lifetime and will be removed at a certain point. The branches are:
- Feature branches
- Release branches
- Bugfix branches

##### Feature branches
**Branches off from:** `dev`
**Merges back to:** `dev`

**Lifetime**: Exists as long as the feature is in development, but will eventually be merged back into `dev` or discarded.

This branch is used to develop new features for the upcoming or a distant future release.

When incorporating feature branches to `dev` using CLI, you can use the following:
```bash
$ git checkout develop
Switched to branch 'develop'
$ git merge --no-ff myfeature
Updating ea1b82a..05e9557
(Summary of changes)
$ git branch -d myfeature
Deleted branch myfeature (was 05e9557).
$ git push origin develop
```

The `--no-ff` flag causes the merge to always create a new commit object. This avoids losing information about the historical existence of a feature branch and groups together all commits that together added the feature. 

[Comparison image](https://nvie.com/img/merge-without-ff@2x.png)

`PR`s by default use the `--no-ff` option unless the commits are rebased or squashed.

#### Release branches
**Branches off from:** `dev`
**Merges back to:** `dev` and `main`

**Lifetime:** Branch is created when the release is about to be rolled out. It will stay there until the release is rolled out definitely.

The branch name should reflect the release version number.

This branch is like last-minute dotting of i's and crossing t's. They also allow for minor bug fixes and preparing meta-data for a release (version number, build dates, etc.)

Branches off from `dev` when the branch almost reflects the desired state of the new release. At least all features that are targeted for the release-to-be-built must be merged in to `dev`. 

Exactly at the start of a release branch that the upcoming release gets assigned a version number. 

Bug fixes may be applied in this branch. Adding large new features here is strictly prohibited. They must be merged into `dev`. 

When finished working on this release and it's ready to be rolled out:
1. The release branch is merged back into `main`.
2. That commit on the `main` should be tagged for easy future reference to this historical version. 
3. The release branch is merged back into `dev`. 
4. The release branch removed.

The above steps in git commands:
```bash
$ git checkout master
Switched to branch 'master'
$ git merge --no-ff release-1.2
Merge made by recursive.
(Summary of changes)
$ git tag -a 1.2
```

You can add tags using the GitHub CLI. Instructions are found [here](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository).

Merging to `dev` branch will possibly create a merge conflict so fix them and commit.
#### Bugfix branches
**Branches off from:** `main` or `dev`
**Merges back to:** `main` and `dev` *according to the branch it was created from.*

**Lifetime:** 

The source of the bugs could be from the production ready code or from the ongoing development code. If the bug is found in the `dev` branch, the same workflow found in the feature branch should be used. 

However, if the bug arises from the necessity to act immediately upon an undesired state of a live production version, follow the following steps.

This workflow helps team members to continue to work on the `dev` branch while another person can prepare a quick production fix.

Naming the bugfix branch also contains the version number of the `main` that was causing the issue. Example, if the `main` tagged with version `1.2` is causing the issue, the bugfix can be version `1.2.1`. 

When done, merge the fix back to `main` then to `dev`. Use `--no-ff` strategy while doing so.

The one exception here is, **if a release branch currently exists, the bugfix changes need to be merged into that release branch instead of the `dev` branch.**
- If the bug fix is crucial for the work on `dev`  branch as well, it's best to be merged there too.

Finally remove the temporary branch.

For more information about Git flow, visit [this](https://nvie.com/posts/a-successful-git-branching-model/) article.
