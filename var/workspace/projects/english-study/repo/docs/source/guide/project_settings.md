---
title: Project settings
short: Project settings
tier: opensource
type: guide
order: 119
order_enterprise: 0
meta_title: Project settings
meta_description: Brief descriptions of all the options available when configuring the project settings
section: "Create & Manage Projects"
parent: "manage_projects_lso"
date: 2024-02-06 22:28:27
---

!!! note Fork note
This repository ships a reduced local doc set. This page stays self-contained instead of linking to upstream-only guide pages that are not present in the fork. For enterprise-only controls, see the local `project_settings_lse.md` page in the same directory.

## General

Use these settings to specify the basic information for a project.

| Field             | Description                                                                                                                            |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **Project Name**  | Enter a name for the project.                                                                                                          |
| **Description**   | Enter a description for the project.                                                                                                   |
| **Color**         | Pick a color so the project is easier to spot in the project list.                                                                     |
| **Task Sampling** | Choose how tasks are served to annotators: **Sequential sampling** keeps Data Manager order, while **Random sampling** shuffles tasks. |

## Labeling interface

The labeling interface is the central configuration point for a project. It determines how tasks are shown to annotators and which controls appear in the editor.

## Annotation

<dl>

<dt>Labeling Instructions</dt>

<dd>

Specify the instructions shown to annotators. This field accepts HTML formatting.

Enable **Show before labeling** to display a pop-up when annotators enter the label stream. If disabled, annotators can still open the instructions from the labeling interface.

</dd>

<dt id="predictions">Live Predictions</dt>

<dd>

Use this section when the project has a connected ML backend or imported predictions.

- **Use predictions to pre-label tasks** enables model-generated or imported pre-annotations.
- **Model or predictions to use** lets you pick the active prediction source.

</dd>

</dl>

## Model

Click **Connect Model** to attach a machine learning backend to the project.

Available options include:

- **Start model training on annotation submission** to trigger backend retraining after new annotations are created.
- **Interactive preannotations** to let the backend respond while an annotator is actively working on a task.
- Overflow-menu actions such as **Start Training**, **Send Test Request**, **Edit**, and **Delete** for an existing model connection.

## Predictions

Use this section to review prediction sets that were imported or generated for the project. Predictions can then be selected from the **Annotation > Live Predictions** controls.

## Cloud storage

This is where you connect project data to external storage providers.

- **Source Cloud Storage** stores the data to be labeled.
- **Target Cloud Storage** stores annotations exported from the project.

## Webhooks

Use webhooks to notify third-party systems when project events happen.

## Danger Zone

These actions can cause data loss and should be used carefully.

- **Drop All Tabs** can help if the Data Manager stops loading correctly.
- **Delete Project** permanently removes project tasks, annotations, and project data.
