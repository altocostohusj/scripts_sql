USE DGEMPRES50;
GO

EXEC sp_NotasOperatorias
    @FechaInicio = '2025-11-11 00:00:00',
    @FechaFin = '2025-11-12 00:00:00',
    @FiltroEntidad = 'NUEVA';
GO