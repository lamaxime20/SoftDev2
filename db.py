import psycopg2
from psycopg2 import OperationalError

host = 'ep-patient-paper-a2tcldxn-pooler.eu-central-1.aws.neon.tech'
dbname = 'MaxDB'
user = 'neondb_owner'
password = 'npg_Njinufa7S2ko'

connection = None

try:
    connection = psycopg2.connect(
        host=host,
        dbname=dbname,
        user=user,
        password=password
    )
    print("Connexion réussie à la base de données PostgreSQL.")
except OperationalError as e:
    print(f"Erreur de connexion : {e}")