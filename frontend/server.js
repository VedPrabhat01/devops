const express = require('express');
const fetch = require('node-fetch');
const app = express();
const PORT = process.env.PORT || 80;
const BACKEND_URL = process.env.BACKEND_URL || 'http://backend:5000';

app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.get('/', (req,res)=> res.sendFile(__dirname + '/index.html'));

app.post('/submit', async (req,res) => {
  try {
    const r = await fetch(BACKEND_URL + '/submit', {
      method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(req.body)
    });
    const text = await r.text();
    res.send(text);
  } catch (e) {
    res.status(500).send(String(e));
  }
});

app.listen(PORT, ()=> console.log('frontend listening on', PORT));
