-- ========================================
-- MIGRATION: Agregar Campos de Suscripción
-- Base de Datos: Supabase (PostgreSQL)
-- Fecha: 2025-11-11
-- ========================================

-- 1. AGREGAR COLUMNAS A LA TABLA INGRESOS
ALTER TABLE ingresos 
ADD COLUMN IF NOT EXISTS fecha_inicio DATE,
ADD COLUMN IF NOT EXISTS fecha_vencimiento DATE,
ADD COLUMN IF NOT EXISTS incluye_inscripcion BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS telefono TEXT,
ADD COLUMN IF NOT EXISTS notas TEXT;

-- 2. AGREGAR COMENTARIOS A LAS COLUMNAS
COMMENT ON COLUMN ingresos.fecha_inicio IS 'Fecha de inicio de la suscripción';
COMMENT ON COLUMN ingresos.fecha_vencimiento IS 'Fecha de vencimiento de la suscripción';
COMMENT ON COLUMN ingresos.incluye_inscripcion IS 'Indica si el pago incluye inscripción ($150)';
COMMENT ON COLUMN ingresos.telefono IS 'Teléfono de contacto del cliente';
COMMENT ON COLUMN ingresos.notas IS 'Notas adicionales sobre el cliente o pago';

-- 3. CREAR ÍNDICES PARA BÚSQUEDAS RÁPIDAS
CREATE INDEX IF NOT EXISTS idx_ingresos_nombre ON ingresos(nombre);
CREATE INDEX IF NOT EXISTS idx_ingresos_vencimiento ON ingresos(fecha_vencimiento);
CREATE INDEX IF NOT EXISTS idx_ingresos_telefono ON ingresos(telefono);
CREATE INDEX IF NOT EXISTS idx_ingresos_tipo ON ingresos(tipo);

-- 4. ACTUALIZAR CONSTRAINT DEL TIPO (si no existe)
DO $$ 
BEGIN
    -- Eliminar constraint anterior si existe
    ALTER TABLE ingresos DROP CONSTRAINT IF EXISTS ingresos_tipo_check;
    
    -- Agregar nuevo constraint con los tipos correctos
    ALTER TABLE ingresos 
    ADD CONSTRAINT ingresos_tipo_check 
    CHECK (tipo IN ('producto', 'visita', 'semana', 'quincena', 'mensualidad', 'otros'));
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error al actualizar constraint: %', SQLERRM;
END $$;

-- 5. VERIFICAR QUE TODO SE HAYA CREADO CORRECTAMENTE
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'ingresos'
AND column_name IN ('fecha_inicio', 'fecha_vencimiento', 'incluye_inscripcion', 'telefono', 'notas')
ORDER BY ordinal_position;

-- 6. MENSAJE DE ÉXITO
DO $$ 
BEGIN
    RAISE NOTICE '✅ Migración completada exitosamente!';
    RAISE NOTICE '✅ Se agregaron los campos de suscripción a la tabla ingresos';
    RAISE NOTICE '✅ Se crearon los índices para búsquedas rápidas';
END $$;
