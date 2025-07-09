/*==============================================================*/
/* Script de generación de datos de prueba                      */
/* IntegraServiciosUD                                           */
/* Fecha: 12/05/2025                                            */
/*==============================================================*/

-- Función para inicializar la semilla aleatoria
CREATE OR REPLACE FUNCTION set_random_seed(seed INTEGER) RETURNS VOID AS $$
BEGIN
    PERFORM setseed(seed::float / 1000000);
END;
$$ LANGUAGE plpgsql;

-- Función para generar horarios aleatorios en formato D00-00,D00-00,...
CREATE OR REPLACE FUNCTION generate_random_schedule() RETURNS VARCHAR AS $$
DECLARE
    days_of_week VARCHAR[] := ARRAY['M', 'T', 'W', 'H', 'F', 'S', 'U'];
    schedule_parts TEXT[] := '{}';
    num_days INTEGER;
    day_letter VARCHAR;
    start_hour INTEGER;
    end_hour INTEGER;
    used_days INTEGER[] := '{}'::INTEGER[];
    day_index INTEGER;
    valid_day BOOLEAN;
BEGIN
    -- Generar entre 1 y 7 entradas de horario
    num_days := 1 + floor(random() * 7)::INTEGER;
    
    FOR i IN 1..num_days LOOP
        -- Seleccionar un día aleatorio que no haya sido usado
        valid_day := FALSE;
        WHILE NOT valid_day LOOP
            day_index := floor(random() * 7) + 1;
            IF NOT (day_index = ANY(used_days)) THEN
                used_days := used_days || day_index;
                valid_day := TRUE;
            END IF;
            -- Prevenir bucle infinito si todos los días están usados
            IF array_length(used_days, 1) >= 7 THEN
                valid_day := TRUE;
            END IF;
        END LOOP;
        
        day_letter := days_of_week[day_index];
        
        -- Generar horas aleatorias (inicio menor que fin) - Horario laboral 7-19
        start_hour := floor(random() * 12) + 7; -- Entre 7 y 18
        end_hour := start_hour + floor(random() * (19 - start_hour) + 1); -- Entre start_hour+1 y 19
        
        -- Añadir al horario en formato D00-00
        schedule_parts := array_append(
            schedule_parts, 
            day_letter || LPAD(start_hour::TEXT, 2, '0') || '-' || LPAD(end_hour::TEXT, 2, '0')
        );
    END LOOP;
    
    -- Convertir el array a string separado por comas
    RETURN array_to_string(schedule_parts, ',');
END;
$$ LANGUAGE plpgsql;

-- Función principal para generar datos de prueba
CREATE OR REPLACE FUNCTION generate_test_data(
    seed INTEGER DEFAULT 12345,
    num_users INTEGER DEFAULT 20, 
    num_buildings INTEGER DEFAULT 5,
    num_spaces_per_building INTEGER DEFAULT 10,
    num_hardware_types INTEGER DEFAULT 5,
    num_hardware INTEGER DEFAULT 50,
    num_warehouses INTEGER DEFAULT 3,
    probability_undelivered FLOAT DEFAULT 0.2,
    probability_unreturned FLOAT DEFAULT 0.3,
    probability_user_is_admin FLOAT DEFAULT 0.2,
    days_span INTEGER DEFAULT 90
) RETURNS VOID AS $$
DECLARE
    current_ts TIMESTAMP;
    user_email VARCHAR;
    user_code INTEGER;
    admin_emails TEXT[];
    user_emails TEXT[];
    hardware_ids INTEGER[];
    building_code INTEGER;
    space_code INTEGER;
    warehouse_code INTEGER;
    hardware_code INTEGER;
    stored_hw_code INTEGER;
    hw_type VARCHAR;
    faculty_name VARCHAR;
    space_type VARCHAR;
    reservation_start TIMESTAMP;
    reservation_end TIMESTAMP;
    handover_date TIMESTAMP;
    return_date TIMESTAMP;
    is_delivered BOOLEAN;
    is_returned BOOLEAN;
    manager_email VARCHAR;
    requester_email VARCHAR;
    res_code INTEGER;
    random_val FLOAT;
    bcrypt_password VARCHAR;
BEGIN
    -- Establecer la semilla aleatoria
    PERFORM set_random_seed(seed);
      -- Fecha actual para base de generación
    current_ts := NOW()::TIMESTAMP; -- Almacena la fecha y hora actual
    
    -- Contraseña encriptada (bcrypt) - La contraseña sin encriptar es 'password123'
    bcrypt_password := '$2a$12$iF4jPph29Xt1OYPTp2Sf2u1crbvNbRJxJboT0vXMh7.iPa99XtWY2';
    
    -- Limpieza de datos existentes (en orden inverso al de creación)
    DELETE FROM ReservedHardware;
    DELETE FROM ReservedSpace;
    DELETE FROM StoredHardware;
    DELETE FROM Warehouse;
    DELETE FROM Space;
    DELETE FROM Hardware;
    DELETE FROM Building;
    DELETE FROM AppUser;
    DELETE FROM Faculty;
    DELETE FROM SpaceType;
    DELETE FROM HardwareType;
    DELETE FROM State;
    DELETE FROM Role;
    
    -- Insertar roles
    INSERT INTO Role (name_role, desc_role) VALUES 
        ('ROLE_ADMIN', 'Administrador con acceso total al sistema'),
        ('ROLE_USER', 'Usuario regular con acceso limitado');
    
    -- Insertar estados
    INSERT INTO State (name_state, desc_state) VALUES 
        ('DISPONIBLE', 'Recurso disponible para reserva'),
        ('RESERVADO', 'Recurso con reserva activa'),
        ('PRESTADO', 'Recurso entregado al solicitante'),
        ('MANTENIMIENTO', 'Recurso en mantenimiento'),
        ('FUERA_DE_SERVICIO', 'Recurso no disponible permanentemente');
    
    -- Insertar tipos de hardware
    FOR i IN 1..num_hardware_types LOOP
        INSERT INTO HardwareType (name_hardwareType, desc_hardwareType) VALUES 
            ('Tipo Hardware ' || i, 'Descripción del tipo de hardware ' || i);
    END LOOP;
    
    -- Insertar tipos de espacios
    INSERT INTO SpaceType (name_spaceType, desc_spaceType) VALUES 
        ('SALON', 'Salón de clases'),
        ('LABORATORIO', 'Laboratorio especializado'),
        ('AUDITORIO', 'Auditorio para eventos'),
        ('OFICINA', 'Espacio de trabajo administrativo'),
        ('SALA_REUNION', 'Sala para reuniones');
    
    -- Insertar facultades
    INSERT INTO Faculty (name_faculty, desc_faculty) VALUES 
        ('Ingeniería', 'Facultad de Ingeniería'),
        ('Ciencias', 'Facultad de Ciencias'),
        ('Artes', 'Facultad de Artes'),
        ('Medicina', 'Facultad de Medicina'),
        ('Derecho', 'Facultad de Ciencias Jurídicas');
    
    -- Crear usuarios
    admin_emails := ARRAY[]::TEXT[];
    user_emails := ARRAY[]::TEXT[];
    
    FOR i IN 1..num_users LOOP
        user_code := i;
        user_email := 'usuario' || i || '@example.com';
        
        -- Determinar el rol
        IF random() < probability_user_is_admin THEN
            INSERT INTO AppUser (email_user, role_user, pass_user, code_user, name_user, phone_user, address_user)
            VALUES (user_email, 'ROLE_ADMIN', bcrypt_password, user_code, 'Usuario ' || i, 3000000000 + i, 'Dirección ' || i);
            admin_emails := array_append(admin_emails, user_email);
        ELSE
            INSERT INTO AppUser (email_user, role_user, pass_user, code_user, name_user, phone_user, address_user)
            VALUES (user_email, 'ROLE_USER', bcrypt_password, user_code, 'Usuario ' || i, 3000000000 + i, 'Dirección ' || i);
            user_emails := array_append(user_emails, user_email);
        END IF;
    END LOOP;
    
    -- Insertar edificios
    FOR i IN 1..num_buildings LOOP
        -- Seleccionar una facultad aleatoriamente
        SELECT name_faculty INTO faculty_name 
        FROM Faculty 
        ORDER BY random() 
        LIMIT 1;
        
        building_code := i;
        
        INSERT INTO Building (code_building, faculty_building, name_building, phone_building, address_building, email_building)
        VALUES (building_code, faculty_name, 'Edificio ' || i, 6000000 + i, 'Dirección Edificio ' || i, 'edificio' || i || '@example.com');
        
        -- Insertar espacios para cada edificio
        FOR j IN 1..num_spaces_per_building LOOP
            -- Seleccionar un tipo de espacio aleatoriamente
            SELECT name_spaceType INTO space_type 
            FROM SpaceType 
            ORDER BY random() 
            LIMIT 1;
            
            space_code := j;
              INSERT INTO Space (building_space, code_space, type_space, state_space, name_space, capacity_space, schedule_space, desc_space)
            VALUES (building_code, space_code, space_type, 'DISPONIBLE', 'Espacio ' || building_code || '-' || space_code, 
                   10 + (random() * 40)::INT, generate_random_schedule(), 'Descripción del espacio ' || building_code || '-' || space_code);
        END LOOP;
        
        -- Insertar almacenes para cada edificio
        FOR j IN 1..num_warehouses LOOP
            IF j <= num_warehouses THEN
                warehouse_code := j;
                
                INSERT INTO Warehouse (building_warehouse, code_warehouse)
                VALUES (building_code, warehouse_code);
            END IF;
        END LOOP;
    END LOOP;
    
    -- Insertar hardware
    FOR i IN 1..num_hardware LOOP
        -- Seleccionar un tipo de hardware aleatoriamente
        SELECT name_hardwareType INTO hw_type 
        FROM HardwareType 
        ORDER BY random() 
        LIMIT 1;
        
        hardware_code := i;
          INSERT INTO Hardware (code_hardware, type_hardware, name_hardware, schedule_hardware, desc_hardware)
        VALUES (hardware_code, hw_type, 'Hardware ' || i, generate_random_schedule(), 'Descripción del hardware ' || i);
        
        hardware_ids := array_append(hardware_ids, hardware_code);
    END LOOP;
    
    -- Insertar hardware almacenado
    stored_hw_code := 1;
    FOR hardware_code IN SELECT unnest(hardware_ids) LOOP
        -- Seleccionar un almacén aleatoriamente
        SELECT building_warehouse, code_warehouse INTO building_code, warehouse_code
        FROM Warehouse
        ORDER BY random()
        LIMIT 1;
        
        INSERT INTO StoredHardware (building_storedhw, warehouse_storedhw, code_storedhw, hardware_storedhw, state_storedhw)
        VALUES (building_code, warehouse_code, stored_hw_code, hardware_code, 'DISPONIBLE');
        
        stored_hw_code := stored_hw_code + 1;
    END LOOP;
    
    -- Crear lista de hardware almacenado
    CREATE TEMP TABLE IF NOT EXISTS temp_stored_hw AS
    SELECT building_storedhw, warehouse_storedhw, code_storedhw
    FROM StoredHardware;
    
    -- Crear lista de espacios
    CREATE TEMP TABLE IF NOT EXISTS temp_spaces AS
    SELECT building_space, code_space
    FROM Space;
      -- Generar reservas de espacios
    res_code := 1;
    FOR i IN 1..((num_buildings * num_spaces_per_building)/2)::INTEGER LOOP
        -- Seleccionar espacio y usuario aleatoriamente
        SELECT building_space, code_space INTO building_code, space_code
        FROM temp_spaces
        ORDER BY random()
        LIMIT 1;
        
        -- Seleccionar requester y manager aleatoriamente
        SELECT user_emails[floor(random() * array_length(user_emails, 1) + 1)] INTO requester_email;
        SELECT admin_emails[floor(random() * array_length(admin_emails, 1) + 1)] INTO manager_email;
        
        -- Generar fechas aleatorias en orden ascendente
        reservation_start := current_ts - (random() * days_span)::INTEGER * INTERVAL '1 day' + 
                           (random() * 12)::INTEGER * INTERVAL '1 hour';
        reservation_end := reservation_start + (random() * 4 + 1)::INTEGER * INTERVAL '1 hour';
        
        -- Determinar si la reserva ha sido entregada
        is_delivered := random() > probability_undelivered;
        
        -- Si la reserva ha sido entregada, establecer fecha de entrega
        IF is_delivered THEN
            handover_date := reservation_start + (random() * 15)::INTEGER * INTERVAL '1 minute';
            
            -- Determinar si la reserva ha sido devuelta
            is_returned := random() > probability_unreturned;
            
            -- Si la reserva ha sido devuelta, establecer fecha de devolución
            IF is_returned THEN
                return_date := reservation_end - (random() * 15)::INTEGER * INTERVAL '1 minute';
            ELSE
                return_date := NULL;
            END IF;
        ELSE
            handover_date := NULL;
            return_date := NULL;
        END IF;
        
        -- Insertar reserva de espacio
        INSERT INTO ReservedSpace (code_resspace, building_resspace, space_resspace, requester_resspace, 
                                 manager_resspace, start_resspace, end_resspace, handover_resspace, 
                                 return_resspace, condrate_resspace, serrate_resspace)
        VALUES (res_code, building_code, space_code, requester_email, manager_email, 
               reservation_start, reservation_end, handover_date, return_date,
               CASE WHEN return_date IS NOT NULL THEN (random() * 5)::INTEGER ELSE NULL END,
               CASE WHEN return_date IS NOT NULL THEN (random() * 5)::INTEGER ELSE NULL END);
        
        -- Actualizar estado del espacio según la reserva
        UPDATE Space
        SET state_space = CASE 
            WHEN handover_date IS NOT NULL AND return_date IS NULL THEN 'PRESTADO'
            WHEN handover_date IS NOT NULL AND return_date IS NOT NULL AND 
                NOW() BETWEEN reservation_start AND reservation_end THEN 'RESERVADO'
            ELSE 'DISPONIBLE'
        END
        WHERE building_space = building_code AND code_space = space_code;
        
        res_code := res_code + 1;
    END LOOP;
    
    -- Generar reservas de hardware
    FOR i IN 1..num_hardware/2 LOOP
        -- Seleccionar hardware almacenado y usuario aleatoriamente
        SELECT building_storedhw, warehouse_storedhw, code_storedhw INTO building_code, warehouse_code, stored_hw_code
        FROM temp_stored_hw
        ORDER BY random()
        LIMIT 1;
        
        -- Seleccionar requester y manager aleatoriamente
        SELECT user_emails[floor(random() * array_length(user_emails, 1) + 1)] INTO requester_email;
        SELECT admin_emails[floor(random() * array_length(admin_emails, 1) + 1)] INTO manager_email;
        
        -- Generar fechas aleatorias en orden ascendente
        reservation_start := current_ts - (random() * days_span)::INTEGER * INTERVAL '1 day' + 
                           (random() * 12)::INTEGER * INTERVAL '1 hour';
        reservation_end := reservation_start + (random() * 24 + 1)::INTEGER * INTERVAL '1 hour';
        
        -- Determinar si la reserva ha sido entregada
        is_delivered := random() > probability_undelivered;
        
        -- Si la reserva ha sido entregada, establecer fecha de entrega
        IF is_delivered THEN
            handover_date := reservation_start + (random() * 15)::INTEGER * INTERVAL '1 minute';
            
            -- Determinar si la reserva ha sido devuelta
            is_returned := random() > probability_unreturned;
            
            -- Si la reserva ha sido devuelta, establecer fecha de devolución
            IF is_returned THEN
                return_date := reservation_end - (random() * 15)::INTEGER * INTERVAL '1 minute';
            ELSE
                return_date := NULL;
            END IF;
        ELSE
            handover_date := NULL;
            return_date := NULL;
        END IF;
        
        -- Verificar que no haya solapamientos
        IF NOT EXISTS (
            SELECT 1 FROM ReservedHardware 
            WHERE building_reshw = building_code AND warehouse_reshw = warehouse_code AND storedhw_reshw = stored_hw_code
            AND (
                (start_reshw <= reservation_start AND end_reshw >= reservation_start) OR
                (start_reshw <= reservation_end AND end_reshw >= reservation_end) OR
                (start_reshw >= reservation_start AND end_reshw <= reservation_end)
            )
        ) THEN
            -- Insertar reserva de hardware
            INSERT INTO ReservedHardware (code_reshw, building_reshw, warehouse_reshw, storedhw_reshw, 
                                       requester_reshw, manager_reshw, start_reshw, end_reshw, 
                                       handover_reshw, return_reshw, condrate_reshw, serrate_reshw)
            VALUES (res_code, building_code, warehouse_code, stored_hw_code, requester_email, manager_email,
                   reservation_start, reservation_end, handover_date, return_date,
                   CASE WHEN return_date IS NOT NULL THEN (random() * 5)::INTEGER ELSE NULL END,
                   CASE WHEN return_date IS NOT NULL THEN (random() * 5)::INTEGER ELSE NULL END);
                  -- Actualizar estado del hardware según la reserva
            UPDATE StoredHardware
            SET state_storedhw = CASE 
                WHEN handover_date IS NOT NULL AND return_date IS NULL THEN 'PRESTADO'
                WHEN handover_date IS NOT NULL AND return_date IS NOT NULL AND 
                    NOW() BETWEEN reservation_start AND reservation_end THEN 'RESERVADO'
                ELSE 'DISPONIBLE'
            END
            WHERE building_storedhw = building_code 
            AND warehouse_storedhw = warehouse_code 
            AND code_storedhw = stored_hw_code;
            
            res_code := res_code + 1;
        END IF;
    END LOOP;
    
    -- Limpiar tablas temporales
    DROP TABLE IF EXISTS temp_stored_hw;
    DROP TABLE IF EXISTS temp_spaces;
    
END;
$$ LANGUAGE plpgsql;

-- Ejecutar la función con parámetros personalizables
SELECT generate_test_data(
    seed := 12345,                     -- Semilla para repetibilidad
    num_users := 50,                   -- Número de usuarios a generar
    num_buildings := 5,                -- Número de edificios
    num_spaces_per_building := 10,     -- Espacios por edificio
    num_hardware_types := 6,           -- Tipos de hardware
    num_hardware := 100,               -- Unidades de hardware
    num_warehouses := 2,               -- Almacenes por edificio
    probability_undelivered := 0.2,    -- Probabilidad de que una reserva no sea entregada
    probability_unreturned := 0.3,     -- Probabilidad de que un recurso entregado no sea devuelto
    probability_user_is_admin := 0.2,  -- Probabilidad de que un usuario sea administrador
    days_span := 90                    -- Rango de días para generación de fechas
);

-- Nota: La contraseña para todos los usuarios es 'password123'
-- pero está encriptada con BCrypt en la base de datos
-- Para cambiar la contraseña, genere un nuevo hash BCrypt y actualice la variable bcrypt_password
