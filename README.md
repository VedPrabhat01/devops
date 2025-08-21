# 🚀 Two-Tier  Web Application on AWS with Docker & Terraform

## 📌 Project Overview
This project demonstrates deployment of a **two-tier application** on AWS.  
It is divided into two EC2 instances:  

- **Frontend Instance (App Server)**  
  - Runs a **python  + server js ** application.  
  - Provides a minimalistic web form to take **user input (username)**.  
  - Sends this input to the backend for storage.  

- **Backend Instance (Database Server)**  
  - Runs a **SQLite Database** in a Docker container.  
  - Stores user information received from the frontend.  

The infrastructure is automated using **Terraform** and application is containerized using **Docker**.  

---

## ⚙️ Tech Stack
- **python** – Frontend Web Application  
- **SQLite** – Database for persistent storage  
- **Docker** – Containerization of app & DB  
- **AWS EC2** – Hosting frontend & backend instances  
- **Terraform** – Infrastructure as Code (IaC)  

---

## 📂 Project Structure
