
SELECT DISTINCT
	SALUNO.RA			[MATRICULA], 
	PPESSOA.NOME		[ALUNO], 
	SCURSO.NOME			[CURSO],
	SSTATUS.DESCRICAO	[SITUACAO_CURSO], 
	SDISCGRADE.CODPERIODO,
	CASE
		WHEN SHABILITACAOALUNO.CODSTATUS = 116 THEN 'MATRIZ ANTERIOR'
		WHEN SHABILITACAOALUNO.CODSTATUS = 19 THEN 'MATRIZ ATUAL'
	END [MATRIZ],
	SMODALIDADECURSO.DESCRICAO [MODALIDADE],
	SDISCIPLINA.NOME	[DISCIPLINA],
	CASE
		WHEN SHISTORICO.CODSTATUSRES IN (2,20) THEN 'Concluído'
		WHEN SHISTORICO.CODSTATUS IN (19) THEN 'Cursando'
	END					[STATUS]
FROM SHABILITACAOALUNO (NOLOCK)
	INNER JOIN SHISTORICO (NOLOCK) ON
			SHISTORICO.RA = SHABILITACAOALUNO.RA
		AND SHISTORICO.IDHABILITACAOFILIAL = SHABILITACAOALUNO.IDHABILITACAOFILIAL
	INNER JOIN SDISCIPLINA (NOLOCK) ON
			SDISCIPLINA.CODDISC = SHISTORICO.CODDISC
	INNER JOIN SALUNO (NOLOCK) ON
			SALUNO.RA = SHABILITACAOALUNO.RA
	INNER JOIN PPESSOA (NOLOCK) ON
			PPESSOA.CODIGO = SALUNO.CODPESSOA
	INNER JOIN SHABILITACAOFILIAL  ON
			SHABILITACAOFILIAL.CODCOLIGADA = SHABILITACAOALUNO.CODCOLIGADA
		AND SHABILITACAOFILIAL.IDHABILITACAOFILIAL = SHABILITACAOALUNO.IDHABILITACAOFILIAL
	INNER JOIN SCURSO (NOLOCK) ON
			SCURSO.CODCOLIGADA = SHABILITACAOFILIAL.CODCOLIGADA
		AND SCURSO.CODCURSO = SHABILITACAOFILIAL.CODCURSO
	INNER JOIN SSTATUS (NOLOCK) ON
			SSTATUS.CODCOLIGADA = SHABILITACAOALUNO.CODCOLIGADA
		AND SSTATUS.CODSTATUS = SHABILITACAOALUNO.CODSTATUS
	INNER JOIN SMODALIDADECURSO (NOLOCK) ON
			SMODALIDADECURSO.CODCOLIGADA = SCURSO.CODCOLIGADA
		AND SMODALIDADECURSO.CODMODALIDADECURSO = SCURSO.CODMODALIDADECURSO
			INNER JOIN SDISCGRADE (NOLOCK) ON
			SDISCGRADE.CODDISC = SDISCIPLINA.CODDISC
WHERE SHABILITACAOALUNO.CODSTATUS IN (116,19)
AND (SHISTORICO.CODSTATUS IN (19, 2) OR SHISTORICO.CODSTATUSRES IN (20))
AND SHABILITACAOALUNO.RA IN (
	SELECT SMATRICPL.RA FROM SPLETIVO (NOLOCK)
		INNER JOIN SMATRICPL (NOLOCK) ON
				SMATRICPL.CODCOLIGADA = SPLETIVO.CODCOLIGADA
			AND SMATRICPL.CODFILIAL = SPLETIVO.CODFILIAL
			AND SMATRICPL.IDPERLET = SPLETIVO.IDPERLET
	WHERE SPLETIVO.CODPERLET = :PERLET
	AND SMATRICPL.CODSTATUS IN (12,101,111))

UNION ALL

SELECT DISTINCT
	SALUNO.RA			[MATRICULA], 
	PPESSOA.NOME		[ALUNO], 
	SCURSO.NOME			[CURSO], 
	SSTATUS.DESCRICAO	[SITUACAO_CURSO],
	SDISCGRADE.CODPERIODO,
	CASE
		WHEN SHABILITACAOALUNO.CODSTATUS = 116 THEN 'MATRIZ ANTERIOR'
		WHEN SHABILITACAOALUNO.CODSTATUS = 19 THEN 'MATRIZ ATUAL'
	END [MATRIZ],
	SMODALIDADECURSO.DESCRICAO	[MODALIDADE],
	SDISCIPLINA.NOME	[DISCIPLINA],
	'Pendente'			[STATUS]
FROM SHABILITACAOALUNO (NOLOCK)
	INNER JOIN SALUNO (NOLOCK) ON
			SALUNO.RA = SHABILITACAOALUNO.RA
	INNER JOIN PPESSOA (NOLOCK) ON
			PPESSOA.CODIGO = SALUNO.CODPESSOA
	INNER JOIN SHABILITACAOFILIAL  ON
			SHABILITACAOFILIAL.CODCOLIGADA = SHABILITACAOALUNO.CODCOLIGADA
		AND SHABILITACAOFILIAL.IDHABILITACAOFILIAL = SHABILITACAOALUNO.IDHABILITACAOFILIAL
	INNER JOIN SCURSO (NOLOCK) ON
			SCURSO.CODCOLIGADA = SHABILITACAOFILIAL.CODCOLIGADA
		AND SCURSO.CODCURSO = SHABILITACAOFILIAL.CODCURSO
	INNER JOIN SSTATUS (NOLOCK) ON
			SSTATUS.CODCOLIGADA = SHABILITACAOALUNO.CODCOLIGADA
		AND SSTATUS.CODSTATUS = SHABILITACAOALUNO.CODSTATUS
	INNER JOIN SMODALIDADECURSO (NOLOCK) ON
			SMODALIDADECURSO.CODCOLIGADA = SCURSO.CODCOLIGADA
		AND SMODALIDADECURSO.CODMODALIDADECURSO = SCURSO.CODMODALIDADECURSO
	INNER JOIN SGRADE (NOLOCK) ON
			SGRADE.CODCOLIGADA = SHABILITACAOFILIAL.CODCOLIGADA
		AND SGRADE.CODGRADE = SHABILITACAOFILIAL.CODGRADE
		AND SGRADE.CODHABILITACAO = SHABILITACAOFILIAL.CODHABILITACAO
		AND SGRADE.CODCURSO = SHABILITACAOFILIAL.CODCURSO
	INNER JOIN SPERIODO (NOLOCK) ON
			SPERIODO.CODCOLIGADA = SGRADE.CODCOLIGADA
		AND SPERIODO.CODGRADE = SGRADE.CODGRADE
		AND SPERIODO.CODCURSO = SGRADE.CODCURSO
		AND SPERIODO.CODHABILITACAO = SGRADE.CODHABILITACAO
	INNER JOIN SDISCGRADE (NOLOCK) ON
			SDISCGRADE.CODCOLIGADA = SPERIODO.CODCOLIGADA
		AND SDISCGRADE.CODGRADE = SPERIODO.CODGRADE
		AND SDISCGRADE.CODCURSO = SPERIODO.CODCURSO
		AND SDISCGRADE.CODHABILITACAO = SPERIODO.CODHABILITACAO
		AND SDISCGRADE.CODPERIODO = SPERIODO.CODPERIODO
	INNER JOIN SDISCIPLINA (NOLOCK) ON
			SDISCIPLINA.CODCOLIGADA = SDISCGRADE.CODCOLIGADA
		AND SDISCIPLINA.CODDISC = SDISCGRADE.CODDISC

WHERE SDISCIPLINA.CODDISC NOT IN (SELECT CODDISC FROM SHISTORICO (NOLOCK) WHERE RA = SHABILITACAOALUNO.RA AND IDHABILITACAOFILIAL = SHABILITACAOALUNO.IDHABILITACAOFILIAL AND (SHISTORICO.CODSTATUS IN (19, 2) OR SHISTORICO.CODSTATUSRES IN (20))) 
AND SHABILITACAOALUNO.CODSTATUS IN (19)
AND SHABILITACAOALUNO.RA IN (
	SELECT SMATRICPL.RA FROM SPLETIVO (NOLOCK)
		INNER JOIN SMATRICPL (NOLOCK) ON
				SMATRICPL.CODCOLIGADA = SPLETIVO.CODCOLIGADA
			AND SMATRICPL.CODFILIAL = SPLETIVO.CODFILIAL
			AND SMATRICPL.IDPERLET = SPLETIVO.IDPERLET
	WHERE SPLETIVO.CODPERLET = :PERLET
	AND SMATRICPL.CODSTATUS IN (12,101,111))