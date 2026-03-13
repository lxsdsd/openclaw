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

!!! error Enterprise
    Many settings are only available in Label Studio Enterprise Edition. If you're using Label Studio Community Edition, see [Label Studio Features](label_studio_compare) to learn more.

## General

Use these settings to specify some basic information about the project. 

| Field          | Description    |
| ------------- | ------------ |
| **Workspace**         | Select a [workspace](workspaces) for the project. |
| **Project Name** | Enter a name for the project. |
| **Description**       | Enter a description for the project. |
| **Color**      | You can select a color for the project. The project is highlighted with this color when viewing the Projects page. |
| **Proxy Credentials**     | Enter proxy credentials. These might be necessary if your task data is protected with basic HTTP access authentication.<br><br> For example, if your Label Studio instance needs to access the internet through a corporate proxy server. |

## Labeling interface

The labeling interface is the central configuration point for projects. This determines how tasks are presented to annotators. 

For information on setting up the labeling interface, see [Labeling configuration](setup). 

## Annotation

Use these settings to configure what options annotators will see and how their labeling tasks are assigned. 

<dl>

<dt>Instructions</dt>

<dd>

Specify instructions to show the annotators. This field accepts HTML formatting. 

Enable **Show before labeling** to display a pop-up message to annotators when they enter the label stream. If disabled, users will need to click the **Show instructions** action at the bottom of the labeling interface. 

</dd>

<dt id="distribute-tasks">Distribute Labeling Tasks</dt>

<dd>

Select how you want to distribute tasks to annotators for labeling. 

| Field          | Description    |
| ------------- | ------------ |
| **Auto**         | Annotators are automatically assigned to tasks, and the option to manually assign annotators is disabled. Automatic assignments are distributed to all users with the Annotator role who are project [members](#Members) <br /><br />You can further define the automatic assignment workflow in the [**Quality** settings](#Quality).  |
| **Manual** | You must [manually assign](manage_data#Assign-annotators-to-tasks) annotators to tasks. Annotators are not be able to view any labeling tasks until they have those tasks manually assigned to them. |

</dd>

<dt>Skip Queue</dt>

<dd>

Select how you want to handle skipped tasks. To disallow skipped tasks, you can hide the **Skip** action under the **Annotating Options** section (see below).

<table>
<thead>
    <tr>
      <th>Field</th>
      <th>Description</th>
    </tr>
</thead>
<tr>
<td>

**Requeue skipped tasks back to the annotator**
</td>
<td>

If an annotator skips a task, the task is moved to the bottom of their queue. They see the task again as they reach the end of their queue. 

If the annotator exits the label stream without labeling the skipped task, and then later re-enters the label stream, whether they see the task again depends on how task distribution is set up. 

* Auto distribution: Whether they see the task again depends on if other annotators have since completed the task. If the task is still incomplete when the annotator re-enters the labeling stream, they can update label and re-submit the task. 
* Manual distribution: The annotator will continue to see the skipped task until it is completed.  

Skipped tasks are not marked as completed, and affect the Overall Project Progress calculation visible from the project Dashboard. (Meaning that the progress for a project that has skipped tasks will be less than 100%.)  

</td>
</tr>
<tr>
<td>

**Requeue skipped tasks to others**
</td>
<td>

If an annotator skips a task, the task is removed from their queue and assigned to a different annotator.

After skipping the task and completing their labeling queue, the annotator cannot return to the skipped task. How the skipped task is completed depends on how task distribution is set up. 

* Auto distribution: The task is automatically assigned to another annotator.
* Manual distribution: The skipped task must be manually assigned to another annotator to be completed. 

If there are no other annotators assigned to the task, or if all annotators skip the task, then the task remains unfinished. Skipped tasks are not marked as completed, and affect the Overall Project Progress calculation visible from the project Dashboard. (Meaning that the progress for a project that has skipped tasks will be less than 100%.) 

</td>
</tr>
<tr>
<td>

**Ignore skipped**
</td>
<td>

How this setting works depends on your labeling distribution method. 

* Auto distribution: If an annotator skips a task, the task is marked as completed and removed from the annotator's queue. 

    If task overlap (as defined in [**Annotations per task minimum**](#overlap)) is set to 1, then the skipped task is not seen again by an annotator. However, if the overlap is greater than 1, then the task is shown to other annotators until the minimum annotations are reached. 

* Manual distribution: If the annotator skips a task, it is removed from their queue. But other annotators assigned to the task will still see it in their queue.  

For both distribution methods, **Ignore skipped** treats skipped tasks differently when it comes to calculating progress. 

Unlike the other skip queue options, in this case skipped tasks are marked as Completed and do not adversely affect the Overall Project Progress calculation visible from the project Dashboard. (Meaning that the progress for a project that has skipped tasks can still be 100%, assuming all tasks are otherwise completed.)

</td>
</tr>
</table>

</dd>

<dt id="annotating-options">Annotating Options</dt>

<dd>

Configure additional settings for annotators. 

| Field          | Description    |
| ------------- | ------------ |
| **Show Skip button**         | Use this to show or hide the **Skip** action for annotators. |
| **Allow empty annotations** | This determines whether annotators can submit a task without making any annotations on it. If enabled, annotators can submit a task even if they haven't added any labels or regions, resulting in an empty annotation. |
| **Show the Data Manager to annotators** | When disabled, annotators can only enter the label stream. When enabled, annotators can access the Data Manager, where they can select which tasks to complete from the Data Manager list. <br /><br />However, some information is still hidden from annotators and they can only view a subset of the Data Manager columns. For example, they cannot see columns such as Annotators, Agreement, Reviewers, and more. |
| **Reveal pre-annotations interactively** | When enabled, pre-annotation regions (such as bounding boxes or text spans) are not automatically displayed to the annotator. Instead, annotators can draw a selection rectangle to reveal pre-annotation regions within that area. This allows annotators to first review the image or text without being influenced by the model’s predictions. Pre-annotation regions must have the attribute `"hidden": true`. <br /><br />This feature is particularly useful when there are multiple low-confidence regions that you prefer not to display all at once to avoid clutter. |
| **Annotators must leave a comment on skip** | When enabled, annotators are required to leave a comment when skipping a task. |

</dd>

<dt id="predictions">Live Predictions</dt>

<dd>

If you have an ML backend or model connected, or if you're using [Prompts](prompts_overview) to generate predictions, you can use this setting to determine whether tasks should be pre-labeled using predictions. For more information, see [Integrate Label Studio into your machine learning pipeline](ml) and [Generate predictions from a prompt](prompts_predictions). 

Use the drop-down menu to select the predictions source. For example, you can select a [connected model](#Model) or a set of [predictions](#Predictions). 


</dd>

<dt id="task-sampling">Task Sampling</dt>

<dd>

Configure the order in which tasks are presented to annotators.  

| Field          | Description    |
| ------------- | ------------ |
| **Uncertainty Sampling**         | This option is for when you are using a machine learning backend and want to employ [active learning](active_learning). Active learning mode continuously trains and reviews predictions from a connected machine learning model, allowing the model to improve iteratively as new annotations are created.<br /><br />When Uncertainty Sampling is enabled, Label Studio strategically selects tasks with the least confident, or most uncertain, prediction scores from your model. The goal is to minimize the amount of data that needs to be labeled while maximizing the performance of the model. |
| **Sequential Sampling** | Tasks are shown to annotators in the same order that they appear on the Data Manager. |
| **Uniform Sampling** | Tasks are shown in random order.  |

</dd>

</dl>


## Review

Use these settings to configure what options reviewers will see. 

<dl>

<dt>Instructions</dt>

<dd>

Specify instructions to show the reviewers. This field accepts HTML formatting. 

Enable **Show before reviewing** to display a pop-up message to reviewers when they enter the label stream. If disabled, users will need to click the **Show instructions** action at the bottom of the labeling interface.  

</dd>

<dt id="reviewing-options">Reviewing Options</dt>

[316 more lines in file. Use offset=201 to continue.]