---
title: Project settings
short: Project settings
tier: enterprise
type: guide
order: 0
order_enterprise: 119
meta_title: Project settings
meta_description: Brief descriptions of all the options available when configuring the project settings
section: "Create & Manage Projects"
parent: "manage_projects"
parent_enterprise: "manage_projects"
date: 2024-02-06 22:28:14
---

!!! note Fork note
The original enterprise page in this fork had been truncated and also depended on many guide pages that are not shipped locally. This version keeps the same major settings areas but documents them in one self-contained page.

!!! note Community vs enterprise
If you are using the community build of this fork, use the local `project_settings.md` page for the smaller settings set.

## General

Use these settings to define the basic project identity and access context.

| Field                 | Description                                                                                 |
| --------------------- | ------------------------------------------------------------------------------------------- |
| **Workspace**         | Select the workspace that owns the project.                                                 |
| **Project Name**      | Enter a name for the project.                                                               |
| **Description**       | Enter a description for the project.                                                        |
| **Color**             | Pick a color so the project stands out in project lists.                                    |
| **Proxy Credentials** | Provide proxy credentials when project data must be fetched through an authenticated proxy. |

## Labeling interface

The labeling interface defines how tasks are rendered to annotators and which controls appear in the editor.

## Annotation

Use these settings to control what annotators see and how tasks are distributed.

### Instructions

- **Annotation Instructions** supports HTML content.
- **Show before labeling** opens the instructions as a pop-up when users enter the labeling stream.

### Task assignment

Choose how tasks are distributed:

| Field         | Description                                                                        |
| ------------- | ---------------------------------------------------------------------------------- |
| **Automatic** | Tasks are assigned automatically to project members with the Annotator role.       |
| **Manual**    | Tasks are assigned directly and annotators only work on the tasks they were given. |

### Task ordering and reservation

When automatic assignment is enabled, you can choose how tasks are served:

- **By Task ID** serves tasks in ascending order.
- **Random** serves tasks in random order.
- **Uncertainty** uses model confidence so lower-confidence items can be labeled first.

Task reservation controls how long a task stays locked to an annotator after they open it. This helps prevent accidental duplicate work while still letting expired tasks return to the queue.

### Annotation options

- **Allow empty annotations** lets annotators submit without creating labels.
- **Show Data Manager to annotators** allows annotators to browse their permitted task subset.
- **Show only columns used in labeling configuration to Annotators** hides unused Data Manager columns from annotators.

### Task skipping

Use these controls to decide whether users can skip tasks and what happens afterward.

- **Allow skipping tasks** shows or hides the skip action.
- **Require comment to skip** forces annotators to explain the skip.
- **Skip Queue** controls whether skipped tasks return to the same annotator, move to another annotator, or are ignored for queueing purposes.

### Task pre-labeling

If the project has a connected ML backend or stored predictions, these controls define how pre-labels appear.

- **Use predictions to pre-label tasks** enables pre-annotation.
- **Model or predictions to use** picks the active prediction source.
- **Reveal pre-annotations interactively** hides model regions until the annotator explicitly reveals them.

## Review

Use these settings to control the reviewer experience.

### Instructions

- **Instructions** supports HTML content for reviewers.
- **Show before reviewing** opens the instructions when reviewers enter the review stream.

### Reviewing options

These controls define when a task counts as reviewed.

| Field                                                       | Description                                                                                     |
| ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| **Task is reviewed after at least one accepted annotation** | One accepted annotation is enough to mark the task as reviewed.                                 |
| **Task is reviewed after all annotations are reviewed**     | Every submitted annotation must be accepted or rejected before the task is considered reviewed. |
| **Review only manually assigned tasks**                     | Reviewers only see tasks explicitly assigned to them.                                           |
| **Show only finished tasks in the review stream**           | Reviewers only see tasks that already satisfied the project completion requirements.            |

### Review ordering and limits

- **By Task ID** keeps review order stable.
- **Random** randomizes the review queue.
- **Task Limit (%)** caps how much of the eligible task set can appear in the review queue when random ordering is used.

### Reject options

Choose what happens when a reviewer rejects an annotation:

- **Requeue rejected annotations back to annotators** sends the work back for correction.
- **Remove rejected annotations from labeling queue** rejects without requeueing.
- **Allow reviewer to choose: Requeue or Remove** exposes both options during review.

### Reviewer Data Manager access

- **Show the Data Manager to reviewers** lets reviewers browse tasks outside the pure review stream.
- **Show unused task data columns to reviewers in the Data Manager** controls whether extra columns stay visible.
- **Show agreement to reviewers in the Data Manager** exposes agreement metrics to reviewers.

## Quality

Use these settings to control overlap, agreement, and evaluator-driven gates.

### Overlap of annotations

These controls define how many independent annotations a task needs and how widely overlap is enforced.

- **Annotations per task** sets the target overlap count.
- **Annotations per task coverage** sets how much of the project must meet that overlap target.
- **Show tasks with overlap first** prioritizes high-overlap tasks.
- **Enforce strict overlap limit** blocks extra submissions once the overlap cap is reached.

### Tasks per annotator limit

Use this section to cap how much work one annotator can complete.

- **Limit by Number of Tasks** sets a hard task count.
- **Limit by Percentage of Tasks** caps work by share of the whole project.

### Annotator evaluation

Evaluate annotators against ground-truth tasks.

- **Onboarding evaluation** serves a set of ground-truth tasks before the main queue.
- **Continuous evaluation** keeps ground-truth checks mixed into ongoing work.
- **Pause annotator on failed evaluation** blocks users who fall below the required score.
- **Score required to pass evaluation** and **Number of tasks for evaluation** define the threshold.

### Agreement

Agreement settings define how consistency between annotators is measured and whether low-agreement tasks receive more attention.

- **Agreement metric** selects the scoring method.
- **Assign additional annotator** automatically adds another annotator to low-agreement tasks.
- **Agreement threshold** defines when the task is considered complete.
- **Maximum additional annotators** caps how far automatic escalation can go.
- **Custom weights** change how individual tags or labels affect the score.

## Members

Use this page to control project membership and project-level roles.

- Project members can be added as **Annotators** or **Reviewers**.
- Automatic distribution can begin assigning work as soon as eligible members are added.
- Manual distribution requires the relevant users to be project members before tasks can be assigned.
- Organization-wide roles such as administrators keep their broader access and are not downgraded at the project level.

## Model

Click **Connect Model** to attach a machine learning backend to the project.

Key options and actions include:

- **Start model training on annotation submission** to call backend training after annotations change.
- **Interactive preannotations** to let the model respond while annotators work.
- Overflow-menu actions such as **Start Training**, **Send Test Request**, **Edit**, and **Delete**.

## Predictions

This section lists prediction sets that were imported, generated externally, or created through batch prediction workflows.

Use **Annotation > Task pre-labeling** to choose which prediction source annotators should see.

## Cloud storage

Use cloud storage connections to move project data in and out of the platform.

- **Source Cloud Storage** is where tasks come from.
- **Target Cloud Storage** is where annotations are synced back out.

## Webhooks

Use webhooks to notify external systems about project events.

## Danger Zone

These actions can cause data loss and should be used carefully.

- **Reset Cache** clears cached labeling state when the UI gets stuck on stale schema data.
- **Drop All Tabs** can help recover the Data Manager if tab state is corrupted.
- **Delete Project** permanently removes the project and its data.
