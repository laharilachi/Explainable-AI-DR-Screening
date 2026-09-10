# Explainable AI for Diabetic Retinopathy Screening

A complete **Explainable AI pipeline** for automated Diabetic Retinopathy (DR) screening, built using **MATLAB** and **Streamlit**. Designed with rural healthcare settings in mind.

---

## Project Overview

Diabetic Retinopathy is one of the leading causes of preventable blindness. Early detection can prevent up to 90% of vision loss. However, rural areas in India face a severe shortage of ophthalmologists.

This project provides an end-to-end screening system that:
- Assesses image quality
- Enhances fundus images
- Classifies DR severity into 5 stages
- Explains the prediction using Grad-CAM
- Offers a simple web interface for practical use

---

## Key Features

- Image Quality Assessment (Blur + Illumination check)
- CLAHE-based Image Enhancement
- EfficientNet-B0 Classification (Transfer Learning)
- Grad-CAM Visual Explainability
- Streamlit Web Interface
- Patient History Tracking
- Telemedicine Workflow Simulation

---

## Results

| Metric                          | Value     |
|--------------------------------|-----------|
| Validation Accuracy            | **91.27%** |
| Referable DR Sensitivity       | **96.31%** |
| Referable DR Specificity      | **96.55%** |

> Referable DR = Moderate + Severe + Proliferative DR

---

## Dataset

- **APTOS 2019** (Resized 224×224 version)
- Classes: `No_DR`, `Mild`, `Moderate`, `Severe`, `Proliferate_DR`

---

## Tech Stack

| Component              | Technology                          |
|-----------------------|-------------------------------------|
| Deep Learning         | MATLAB Deep Learning Toolbox        |
| Image Processing      | MATLAB Image Processing Toolbox     |
| Model                 | EfficientNet-B0                     |
| Explainability        | Grad-CAM                            |
| Frontend              | Streamlit (Python)                  |
| Simulation            | MATLAB Script                       |

---

## Project Structure
