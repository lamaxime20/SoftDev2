from flask import Flask, request, jsonify, render_template
from db import connection
import re
import threading
import time

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("index.html")  # sert la page principale

@app.route('/formulaire', methods=['POST'])
def handle_form():
    nom = request.form.get('nom', '').strip()
    email = request.form.get('email', '').strip()
    message = request.form.get('message', '').strip()

    if not nom or not email or not message:
        return "❌ Tous les champs sont obligatoires.", 400

    if not re.match(r"[^@]+@[^@]+\.[^@]+", email):
        return "❌ Adresse email invalide.", 400

    try:
        with connection.cursor() as cursor:
            cursor.execute("CALL CreationReq(%s, %s, %s)", (nom, email, message))
            connection.commit()
        return "✅ Requête envoyée avec succès !", 200
    except Exception as e:
        connection.rollback()  # annule la transaction en erreur
        print("❌ Erreur côté serveur :", e)
        return f"❌ Erreur : {e}", 500

# Fonction pour réveiller la base Neon
def wake_up_db():
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1;")
        print("✅ Base de données réveillée avec succès.")
    except Exception as e:
        print(f"⚠️ Échec du réveil de la base : {e}")

# Fonction pour garder la base active
def keep_db_awake(interval=600):  # 600 secondes = 10 minutes
    def ping():
        while True:
            try:
                with connection.cursor() as cursor:
                    cursor.execute("SELECT 1;")
                print("🔄 Ping DB réussi")
            except Exception as e:
                print(f"⚠️ Ping DB échoué : {e}")
            time.sleep(interval)
    thread = threading.Thread(target=ping, daemon=True)
    thread.start()

if __name__ == '__main__':
    wake_up_db()
    keep_db_awake()
    app.run(host="0.0.0.0", port=10000)