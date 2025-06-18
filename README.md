

<!-- PROJECT LOGO -->
<p align="center">

  <h1 align="center">LIFE‑LINK</h1>
  <p align="center">
    🌐 A full‑stack Vite‑React‑Tailwind & Node/Express web application for seamless user‑admin interaction.
  </p>
</p>

---
---

## 🔍 About

**LIFE‑LINK** is a modern web platform that connects users with an admin panel for managing content and data. Built with **Vite + React + Tailwind CSS** on the front end and **Node.js + Express** on the back end, it’s optimized for performance, scalability, and a smooth developer experience.

---

## 🛠️ Tech Stack

| Layer      | Technology              |
| ---------- | ----------------------- |
| Frontend   | Vite · React · Tailwind |
| Admin Panel| Vite · React · Tailwind |
| Backend    | Node.js · Express       |
| Database   | (Configure in `.env`)   |               

---

-------------------------------------------------------- How to implement ---------------------------------------------------------------------------

Here’s a super‑concise, terminal‑focused setup guide—point‑by‑point:

Clone & enter project



command in Terminal >>  **git clone https://github.com/AbirChakraborty1703/LIFE-LINK.git**

command in Terminal >>  **cd LIFE-LINK/ITproject**

command in Terminal >>  **Install dependencies**



command in Terminal >>  **cd backend   && npm install   && cd ..**
command in Terminal >>   **cd frontend  && npm install   && cd ..**
command in Terminal >>    **cd admin     && npm install   && cd ..**
Configure env files

Copy each  → **.env in backend**, **frontend**, **admin**

In (backend/.env), set:



**MONGO_URI=<your MongoDB Atlas connection string>
PORT=5000
JWT_SECRET=<your_jwt_secret>
Connect via MongoDB Compass**

Launch Compass

Paste the same MONGO_URI from backend/.env

Click “Connect”

(Optional) Seed initial admin


command in Terminal >>   **cd backend**

[ node seeder.js
cd ..
Start services ]

**Backend**


command in Terminal >>  **npm run dev**
Frontend


command in Terminal >>  **cd frontend**
command in Terminal >>   **npm run dev**

Access apps

**Frontend: http://localhost:3000**

**Admin: http://localhost:5173**
– API logs on port 5000

That’s it—everything wired up, Compass‑connected, and running!

