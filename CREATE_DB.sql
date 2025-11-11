-- =====================================================
-- Script de Creación de Base de Datos
-- Dancor Sport Gym - Control de Caja
-- Para Supabase (PostgreSQL)
-- =====================================================

-- IMPORTANTE: Ejecuta este script por secciones en Supabase
-- Si da error, ejecuta cada CREATE TABLE por separado

-- Eliminar tablas si existen (opcional, comentar en primera ejecución)
-- DROP TABLE IF EXISTS cierres_diarios CASCADE;
-- DROP TABLE IF EXISTS gastos CASCADE;
-- DROP TABLE IF EXISTS ingresos CASCADE;

-- =====================================================
-- TABLA: ingresos
-- Almacena todos los ingresos del gimnasio
-- =====================================================
CREATE TABLE IF NOT EXISTS ingresos (
    id BIGSERIAL PRIMARY KEY,
    concepto TEXT NOT NULL,
    monto NUMERIC(10, 2) NOT NULL,
    fecha TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    nombre TEXT,
    tipo TEXT NOT NULL,
    fecha_inicio DATE,
    fecha_vencimiento DATE,
    incluye_inscripcion BOOLEAN DEFAULT FALSE,
    telefono TEXT,
    notas TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT monto_positivo CHECK (monto >= 0),
    CONSTRAINT tipo_valido CHECK (tipo IN ('visita', 'semana', 'quincena', 'mensualidad', 'otros'))
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_ingresos_fecha ON ingresos(fecha);
CREATE INDEX IF NOT EXISTS idx_ingresos_tipo ON ingresos(tipo);
CREATE INDEX IF NOT EXISTS idx_ingresos_fecha_date ON ingresos((fecha::date));
CREATE INDEX IF NOT EXISTS idx_ingresos_nombre ON ingresos(nombre);
CREATE INDEX IF NOT EXISTS idx_ingresos_vencimiento ON ingresos(fecha_vencimiento);
CREATE INDEX IF NOT EXISTS idx_ingresos_telefono ON ingresos(telefono);

-- Comentarios de la tabla
COMMENT ON TABLE ingresos IS 'Registro de todos los ingresos del gimnasio';
COMMENT ON COLUMN ingresos.concepto IS 'Descripción del ingreso (Visita, Semana, etc.)';
COMMENT ON COLUMN ingresos.monto IS 'Monto del ingreso en pesos';
COMMENT ON COLUMN ingresos.fecha IS 'Fecha y hora del registro';
COMMENT ON COLUMN ingresos.nombre IS 'Nombre del cliente (requerido para semana, quincena, mensualidad)';
COMMENT ON COLUMN ingresos.tipo IS 'Tipo de ingreso: visita, semana, quincena, mensualidad, otros';
COMMENT ON COLUMN ingresos.fecha_inicio IS 'Fecha de inicio de la suscripción';
COMMENT ON COLUMN ingresos.fecha_vencimiento IS 'Fecha de vencimiento de la suscripción';
COMMENT ON COLUMN ingresos.incluye_inscripcion IS 'Indica si la mensualidad incluye inscripción';
COMMENT ON COLUMN ingresos.telefono IS 'Teléfono de contacto del cliente';
COMMENT ON COLUMN ingresos.notas IS 'Notas adicionales sobre el ingreso o cliente';

-- =====================================================
-- TABLA: gastos
-- Almacena todos los gastos del gimnasio
-- =====================================================
CREATE TABLE IF NOT EXISTS gastos (
    id BIGSERIAL PRIMARY KEY,
    concepto TEXT NOT NULL,
    monto NUMERIC(10, 2) NOT NULL,
    fecha TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT monto_gasto_positivo CHECK (monto >= 0)
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_gastos_fecha ON gastos(fecha);
CREATE INDEX IF NOT EXISTS idx_gastos_fecha_date ON gastos((fecha::date));

-- Comentarios de la tabla
COMMENT ON TABLE gastos IS 'Registro de todos los gastos del gimnasio';
COMMENT ON COLUMN gastos.concepto IS 'Descripción del gasto (compras, servicios, etc.)';
COMMENT ON COLUMN gastos.monto IS 'Monto del gasto en pesos';
COMMENT ON COLUMN gastos.fecha IS 'Fecha y hora del registro';

-- =====================================================
-- TABLA: cierres_diarios
-- Almacena los resúmenes diarios (cierres de caja)
-- =====================================================
CREATE TABLE IF NOT EXISTS cierres_diarios (
    id BIGSERIAL PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    ingresos_totales NUMERIC(10, 2) NOT NULL DEFAULT 0,
    gastos_totales NUMERIC(10, 2) NOT NULL DEFAULT 0,
    resultado_final NUMERIC(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT ingresos_positivos CHECK (ingresos_totales >= 0),
    CONSTRAINT gastos_positivos CHECK (gastos_totales >= 0)
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_cierres_fecha ON cierres_diarios(fecha DESC);

-- Comentarios de la tabla
COMMENT ON TABLE cierres_diarios IS 'Resumen diario de ingresos y gastos (cierre de caja)';
COMMENT ON COLUMN cierres_diarios.fecha IS 'Fecha del cierre diario';
COMMENT ON COLUMN cierres_diarios.ingresos_totales IS 'Suma total de ingresos del día';
COMMENT ON COLUMN cierres_diarios.gastos_totales IS 'Suma total de gastos del día';
COMMENT ON COLUMN cierres_diarios.resultado_final IS 'Resultado del día (ingresos - gastos)';

-- =====================================================
-- FUNCIONES Y TRIGGERS
-- =====================================================

-- Función para actualizar el campo updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para ingresos
DROP TRIGGER IF EXISTS update_ingresos_updated_at ON ingresos;
CREATE TRIGGER update_ingresos_updated_at 
    BEFORE UPDATE ON ingresos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para gastos
DROP TRIGGER IF EXISTS update_gastos_updated_at ON gastos;
CREATE TRIGGER update_gastos_updated_at 
    BEFORE UPDATE ON gastos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para cierres_diarios
DROP TRIGGER IF EXISTS update_cierres_updated_at ON cierres_diarios;
CREATE TRIGGER update_cierres_updated_at 
    BEFORE UPDATE ON cierres_diarios
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- FUNCIONES AUXILIARES
-- =====================================================

-- Función para calcular el total de ingresos de una fecha
CREATE OR REPLACE FUNCTION calcular_ingresos_dia(fecha_consulta DATE)
RETURNS NUMERIC(10, 2) AS $$
DECLARE
    total NUMERIC(10, 2);
BEGIN
    SELECT COALESCE(SUM(monto), 0)
    INTO total
    FROM ingresos
    WHERE fecha::date = fecha_consulta;
    
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- Función para calcular el total de gastos de una fecha
CREATE OR REPLACE FUNCTION calcular_gastos_dia(fecha_consulta DATE)
RETURNS NUMERIC(10, 2) AS $$
DECLARE
    total NUMERIC(10, 2);
BEGIN
    SELECT COALESCE(SUM(monto), 0)
    INTO total
    FROM gastos
    WHERE fecha::date = fecha_consulta;
    
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- Función para crear o actualizar un cierre diario
CREATE OR REPLACE FUNCTION crear_cierre_diario(fecha_cierre DATE)
RETURNS TABLE(
    id BIGINT,
    fecha DATE,
    ingresos_totales NUMERIC(10, 2),
    gastos_totales NUMERIC(10, 2),
    resultado_final NUMERIC(10, 2)
) AS $$
DECLARE
    total_ingresos NUMERIC(10, 2);
    total_gastos NUMERIC(10, 2);
    resultado NUMERIC(10, 2);
BEGIN
    -- Calcular totales
    total_ingresos := calcular_ingresos_dia(fecha_cierre);
    total_gastos := calcular_gastos_dia(fecha_cierre);
    resultado := total_ingresos - total_gastos;
    
    -- Insertar o actualizar el cierre
    INSERT INTO cierres_diarios (fecha, ingresos_totales, gastos_totales, resultado_final)
    VALUES (fecha_cierre, total_ingresos, total_gastos, resultado)
    ON CONFLICT (fecha) 
    DO UPDATE SET 
        ingresos_totales = EXCLUDED.ingresos_totales,
        gastos_totales = EXCLUDED.gastos_totales,
        resultado_final = EXCLUDED.resultado_final,
        updated_at = NOW();
    
    -- Retornar el cierre creado/actualizado
    RETURN QUERY
    SELECT c.id, c.fecha, c.ingresos_totales, c.gastos_totales, c.resultado_final
    FROM cierres_diarios c
    WHERE c.fecha = fecha_cierre;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- POLÍTICAS DE SEGURIDAD (Row Level Security - RLS)
-- Opcional: Habilitar si necesitas control de acceso
-- =====================================================

-- Habilitar RLS (descomenta si lo necesitas)
-- ALTER TABLE ingresos ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE gastos ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE cierres_diarios ENABLE ROW LEVEL SECURITY;

-- Política de ejemplo: permitir todo (descomenta y modifica según necesites)
-- CREATE POLICY "Permitir todo en ingresos" ON ingresos FOR ALL USING (true);
-- CREATE POLICY "Permitir todo en gastos" ON gastos FOR ALL USING (true);
-- CREATE POLICY "Permitir todo en cierres" ON cierres_diarios FOR ALL USING (true);

-- =====================================================
-- DATOS DE EJEMPLO (Opcional - para pruebas)
-- =====================================================

-- Insertar algunos datos de ejemplo
INSERT INTO ingresos (concepto, monto, fecha, nombre, tipo, fecha_inicio, fecha_vencimiento, incluye_inscripcion, telefono) VALUES
    ('Visita', 40.00, NOW(), NULL, 'visita', CURRENT_DATE, CURRENT_DATE, FALSE, NULL),
    ('Semana', 180.00, NOW(), 'Juan Pérez', 'semana', CURRENT_DATE, CURRENT_DATE + INTERVAL '7 days', FALSE, '555-1234'),
    ('Mensualidad + Inscripción', 550.00, NOW() - INTERVAL '1 day', 'María García', 'mensualidad', CURRENT_DATE - 1, CURRENT_DATE + INTERVAL '29 days', TRUE, '555-5678'),
    ('Quincena', 260.00, NOW(), 'Pedro López', 'quincena', CURRENT_DATE, CURRENT_DATE + INTERVAL '15 days', FALSE, '555-9999'),
    ('Venta de agua', 15.00, NOW(), NULL, 'otros', NULL, NULL, FALSE, NULL);

INSERT INTO gastos (concepto, monto, fecha) VALUES
    ('Compra de bebidas', 250.00, NOW()),
    ('Material de limpieza', 120.00, NOW() - INTERVAL '1 day'),
    ('Pago de servicios', 500.00, NOW() - INTERVAL '2 days');

-- Crear cierre del día de hoy
SELECT * FROM crear_cierre_diario(CURRENT_DATE);

-- =====================================================
-- VISTAS ÚTILES (Opcional)
-- =====================================================

-- Vista de resumen diario
CREATE OR REPLACE VIEW vista_resumen_diario AS
SELECT 
    i.fecha::date as fecha,
    COALESCE(SUM(i.monto), 0) as ingresos_totales,
    COALESCE((SELECT SUM(g.monto) FROM gastos g WHERE g.fecha::date = i.fecha::date), 0) as gastos_totales,
    COALESCE(SUM(i.monto), 0) - COALESCE((SELECT SUM(g.monto) FROM gastos g WHERE g.fecha::date = i.fecha::date), 0) as resultado_final
FROM ingresos i
GROUP BY i.fecha::date
ORDER BY i.fecha::date DESC;

-- Vista de ingresos por tipo
CREATE OR REPLACE VIEW vista_ingresos_por_tipo AS
SELECT 
    tipo,
    COUNT(*) as cantidad,
    SUM(monto) as total,
    AVG(monto) as promedio,
    fecha::date as fecha
FROM ingresos
GROUP BY tipo, fecha::date
ORDER BY fecha::date DESC, tipo;

-- =====================================================
-- CONSULTAS ÚTILES
-- =====================================================

-- Ver todos los ingresos del día actual
-- SELECT * FROM ingresos WHERE fecha::date = CURRENT_DATE ORDER BY fecha DESC;

-- Ver todos los gastos del día actual
-- SELECT * FROM gastos WHERE fecha::date = CURRENT_DATE ORDER BY fecha DESC;

-- Ver el resumen de hoy
-- SELECT * FROM vista_resumen_diario WHERE fecha = CURRENT_DATE;

-- Ver todos los cierres diarios
-- SELECT * FROM cierres_diarios ORDER BY fecha DESC;

-- Crear cierre del día actual
-- SELECT * FROM crear_cierre_diario(CURRENT_DATE);

-- Ver ingresos por tipo del mes actual
-- SELECT tipo, COUNT(*) as cantidad, SUM(monto) as total
-- FROM ingresos
-- WHERE DATE_TRUNC('month', fecha) = DATE_TRUNC('month', CURRENT_TIMESTAMP)
-- GROUP BY tipo;

-- Ver suscripciones activas (no vencidas)
-- SELECT nombre, tipo, monto, fecha_inicio, fecha_vencimiento, telefono
-- FROM ingresos 
-- WHERE fecha_vencimiento >= CURRENT_DATE 
-- AND tipo IN ('semana', 'quincena', 'mensualidad')
-- ORDER BY fecha_vencimiento ASC;

-- Ver suscripciones que vencen pronto (próximos 3 días)
-- SELECT nombre, tipo, fecha_vencimiento, telefono,
--        (fecha_vencimiento - CURRENT_DATE) as dias_restantes
-- FROM ingresos 
-- WHERE fecha_vencimiento BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '3 days'
-- AND tipo IN ('semana', 'quincena', 'mensualidad')
-- ORDER BY fecha_vencimiento ASC;

-- Ver suscripciones vencidas
-- SELECT nombre, tipo, fecha_vencimiento, telefono,
--        (CURRENT_DATE - fecha_vencimiento) as dias_vencidos
-- FROM ingresos 
-- WHERE fecha_vencimiento < CURRENT_DATE 
-- AND tipo IN ('semana', 'quincena', 'mensualidad')
-- ORDER BY fecha_vencimiento DESC;

-- Buscar cliente por nombre
-- SELECT * FROM ingresos 
-- WHERE nombre ILIKE '%juan%' 
-- ORDER BY fecha DESC;

-- Ver historial completo de un cliente
-- SELECT concepto, monto, fecha, fecha_inicio, fecha_vencimiento, tipo, incluye_inscripcion
-- FROM ingresos 
-- WHERE nombre = 'Juan Pérez'
-- ORDER BY fecha DESC;

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================

/*
1. CONFIGURACIÓN DE SUPABASE:
   - Copia y pega este script en el SQL Editor de Supabase
   - Ejecuta el script completo
   - Verifica que las tablas se crearon correctamente

2. CONEXIÓN DESDE FLUTTER:
   - Instala el paquete: supabase_flutter
   - Obtén tu URL y API Key desde Supabase Dashboard
   - Configura la conexión en tu app

3. SEGURIDAD:
   - Las políticas RLS están comentadas por defecto
   - Para producción, habilita RLS y configura políticas apropiadas
   - Considera agregar autenticación si es necesario

4. RESPALDOS:
   - Supabase hace respaldos automáticos
   - También puedes exportar los datos manualmente
   - Considera implementar exportación a CSV desde la app

5. ÍNDICES:
   - Los índices mejoran el rendimiento de las consultas
   - Si tienes muchos datos, monitorea el rendimiento
   - Agrega más índices si es necesario

6. MANTENIMIENTO:
   - Revisa periódicamente el tamaño de la base de datos
   - Considera archivar datos antiguos si es necesario
   - Monitorea el uso de la cuota de Supabase
*/

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================
