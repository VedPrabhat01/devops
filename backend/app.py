from flask import Flask, request, jsonify
import sqlite3, os

DB = 'users.db'
app = Flask(__name__)

def init_db():
    conn = sqlite3.connect(DB)
    conn.execute('''CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT)''')
    conn.commit()
    conn.close()

@app.route('/submit', methods=['POST'])
def submit():
    data = request.get_json() or request.form
    name = data.get('name')
    email = data.get('email')
    conn = sqlite3.connect(DB)
    cur = conn.cursor()
    cur.execute('INSERT INTO users (name,email) VALUES (?,?)', (name,email))
    conn.commit()
    conn.close()
    return jsonify({'status': 'Form Submission Successfull !!!'})

@app.route('/users', methods=['GET'])
def users():
    conn = sqlite3.connect(DB)
    cur = conn.cursor()
    cur.execute('SELECT id,name,email FROM users')
    rows = cur.fetchall()
    conn.close()
    return jsonify(rows)

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000)
