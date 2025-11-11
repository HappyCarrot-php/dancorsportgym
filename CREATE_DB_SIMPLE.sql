-- =====================================================
-- SCRIPT SIMPLE PARA SUPABASE
-- Dancor Sport Gym - Control de Caja
-- Ejecuta este script completo o por secciones
-- =====================================================

-- PASO 1: CREAR TABLAS
-- =====================================================

-- Tabla de ingresos
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
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de gastos
CREATE TABLE IF NOT EXISTS gastos (
    id BIGSERIAL PRIMARY KEY,
    concepto TEXT NOT NULL,
    monto NUMERIC(10, 2) NOT NULL,
    fecha TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de cierres diarios
CREATE TABLE IF NOT EXISTS cierres_diarios (
    id BIGSERIAL PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    ingresos_totales NUMERIC(10, 2) NOT NULL DEFAULT 0,
    gastos_totales NUMERIC(10, 2) NOT NULL DEFAULT 0,
    resultado_final NUMERIC(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PASO 2: CREAR ÍNDICES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_ingresos_fecha ON ingresos(fecha);
CREATE INDEX IF NOT EXISTS idx_ingresos_tipo ON ingresos(tipo);
CREATE INDEX IF NOT EXISTS idx_ingresos_nombre ON ingresos(nombre);
CREATE INDEX IF NOT EXISTS idx_ingresos_vencimiento ON ingresos(fecha_vencimiento);
CREATE INDEX IF NOT EXISTS idx_gastos_fecha ON gastos(fecha);
CREATE INDEX IF NOT EXISTS idx_cierres_fecha ON cierres_diarios(fecha DESC);

-- PASO 3: HABILITAR RLS (Row Level Security)
-- =====================================================

ALTER TABLE ingresos ENABLE ROW LEVEL SECURITY;
ALTER TABLE gastos ENABLE ROW LEVEL SECURITY;
ALTER TABLE cierres_diarios ENABLE ROW LEVEL SECURITY;

-- PASO 4: CREAR POLÍTICAS (permite acceso a todos)
-- =====================================================

-- Política para ingresos
CREATE POLICY "Permitir acceso a ingresos" ON ingresos FOR ALL USING (true);

-- Política para gastos
CREATE POLICY "Permitir acceso a gastos" ON gastos FOR ALL USING (true);

-- Política para cierres
CREATE POLICY "Permitir acceso a cierres" ON cierres_diarios FOR ALL USING (true);

-- PASO 5: INSERTAR DATOS DE PRUEBA
-- =====================================================

-- Ejemplo de visita (sin vencimiento)
INSERT INTO ingresos (concepto, monto, fecha, nombre, tipo, fecha_inicio, fecha_vencimiento) VALUES
    ('Visita', 40.00, NOW(), NULL, 'visita', CURRENT_DATE, CURRENT_DATE);

-- Ejemplo de semana (vence en 7 días)
INSERT INTO ingresos (concepto, monto, fecha, nombre, tipo, fecha_inicio, fecha_vencimiento, telefono) VALUES
    ('Semana', 180.00, NOW(), 'Juan Pérez', 'semana', CURRENT_DATE, CURRENT_DATE + INTERVAL '7 days', '555-1234');

-- Ejemplo de mensualidad (vence en 30 días)
INSERT INTO ingresos (concepto, monto, fecha, nombre, tipo, fecha_inicio, fecha_vencimiento, incluye_inscripcion, telefono) VALUES
    ('Mensualidad + Inscripción', 550.00, NOW(), 'María García', 'mensualidad', CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', TRUE, '555-5678');

INSERT INTO gastos (concepto, monto, fecha) VALUES
    ('Compra de bebidas', 250.00, NOW());

-- =====================================================
-- CONSULTAS ÚTILES
-- =====================================================

-- Ver todos los ingresos con vencimiento
-- SELECT * FROM ingresos ORDER BY fecha DESC;

-- Ver todos los gastos
-- SELECT * FROM gastos ORDER BY fecha DESC;

-- Ver resumen del día actual
-- SELECT 
--     (SELECT COALESCE(SUM(monto), 0) FROM ingresos WHERE fecha::date = CURRENT_DATE) as ingresos,
--     (SELECT COALESCE(SUM(monto), 0) FROM gastos WHERE fecha::date = CURRENT_DATE) as gastos;

-- Ver suscripciones activas (no vencidas)
-- SELECT nombre, tipo, fecha_inicio, fecha_vencimiento, telefono
-- FROM ingresos 
-- WHERE fecha_vencimiento >= CURRENT_DATE 
-- AND tipo IN ('semana', 'quincena', 'mensualidad')
-- ORDER BY fecha_vencimiento ASC;

-- Ver suscripciones que vencen pronto (próximos 3 días)
-- SELECT nombre, tipo, fecha_vencimiento, telefono
-- FROM ingresos 
-- WHERE fecha_vencimiento BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '3 days'
-- AND tipo IN ('semana', 'quincena', 'mensualidad')
-- ORDER BY fecha_vencimiento ASC;

-- Ver suscripciones vencidas
-- SELECT nombre, tipo, fecha_vencimiento, telefono
-- FROM ingresos 
-- WHERE fecha_vencimiento < CURRENT_DATE 
-- AND tipo IN ('semana', 'quincena', 'mensualidad')
-- ORDER BY fecha_vencimiento DESC;

-- Buscar cliente por nombre
-- SELECT * FROM ingresos 
-- WHERE nombre ILIKE '%juan%' 
-- ORDER BY fecha DESC;

-- Ver historial de un cliente
-- SELECT concepto, monto, fecha, fecha_inicio, fecha_vencimiento, tipo
-- FROM ingresos 
-- WHERE nombre = 'Juan Pérez'
-- ORDER BY fecha DESC;
