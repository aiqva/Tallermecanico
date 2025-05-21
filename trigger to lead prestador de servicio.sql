-- ...existing code...

DELIMITER $$

CREATE TRIGGER chk_prestador_es_contacto
AFTER INSERT ON Facturacion
FOR EACH ROW
BEGIN
    DECLARE contacto_id INT;
    SELECT ContactoID INTO contacto_id
    FROM PrestacionServicios
    WHERE PrestacionServicioID = NEW.PrestacionServicioID;
    IF contacto_id <> NEW.PrestadorID THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El PrestadorID debe coincidir con el ContactoID de la PrestacionServicio';
    END IF;
END$$

CREATE TRIGGER chk_prestador_es_contacto_update
AFTER UPDATE ON Facturacion
FOR EACH ROW
BEGIN
    DECLARE contacto_id INT;
    SELECT ContactoID INTO contacto_id
    FROM PrestacionServicios
    WHERE PrestacionServicioID = NEW.PrestacionServicioID;
    IF contacto_id <> NEW.PrestadorID THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El PrestadorID debe coincidir con el ContactoID de la PrestacionServicio';
    END IF;
END$$

DELIMITER ;

-- ...existing code...