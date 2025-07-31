CREATE TABLE Requetes (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(60) NOT NULL,
    email TEXT NOT NULL,
    message TEXT NOT NULL,
    Date_creation DATE NOT NULL
);

CREATE TABLE Notification (
    notif TEXT NOT NULL,
    exist BOOLEAN NOT NULL,
    CONSTRAINT Notification_cc0 PRIMARY KEY(notif)
);

INSERT INTO Notification(notif, exist)
VALUES ('Requete', FALSE);

-- Triggers
-- Trigger pour voir une modification de Requetes
CREATE OR REPLACE FUNCTION notify_Requetes() RETURNS trigger AS $$
BEGIN
  UPDATE Notification
  SET exist = TRUE
  WHERE notif = 'Requete'
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER donnees_update_trigger
AFTER INSERT OR UPDATE OR DELETE ON Requetes
FOR EACH ROW
EXECUTE FUNCTION notify_Requetes();

-- Procedure de notif
CREATE OR REPLACE FUNCTION getNotification(nom_in TEXT)
LANGUAGE plpgsql
RETURNS BOOLEAN
DECLARE exist_in BOOLEAN
AS $$
BEGIN
    SELECT exist
    INTO exist_in
    FROM Notification
    WHERE notif = nom_in;

    UPDATE Notification
    SET exist = FALSE
    WHERE notif = 'Requete'
    RETURN exist_in;
END;
$$;

-- 🔵 Procédure d’insertion
CREATE OR REPLACE PROCEDURE CreationReq(nom_in TEXT, email_in TEXT, message_in TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Requetes (nom, email, message, Date_creation)
    VALUES (nom_in, email_in, message_in, CURRENT_DATE);
END;
$$;

-- 🟢 Procédure de modification
CREATE OR REPLACE PROCEDURE ModifReq(id_in INT, nom_in TEXT, email_in TEXT, message_in TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Requetes
    SET nom = nom_in,
        email = email_in,
        message = message_in,
        Date_creation = CURRENT_DATE
    WHERE id = id_in;
END;
$$;

-- 🔴 Procédure de suppression
CREATE OR REPLACE PROCEDURE SuppReq(id_in INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Requetes
    WHERE id = id_in;
END;
$$;

-- 🟣 Fonction de récupération
CREATE OR REPLACE FUNCTION AvoirReq()
RETURNS TABLE (
    id_in INT,
    nom_in VARCHAR(60),
    email_in TEXT,
    message_in TEXT,
    Date_creation_in DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT id, nom, email, message, Date_creation
    FROM Requetes
    ORDER BY Date_creation DESC;
END;
$$;