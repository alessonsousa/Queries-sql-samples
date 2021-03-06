SELECT 
	SMATRICPL.RA											[MATRICULA],
	UPPER(PPESSOA.NOME)										[ALUNO],
	SPLETIVO.CODPERLET										[PERIODO_LETIVO],
	SCURSO.NOME												[CURSO],
	SSTATUS.CODSTATUS										[CODSTATUS_PL],
	SSTATUS.DESCRICAO										[STATUS_PL],
	CONVERT(VARCHAR(12), SMATRICPL.DTMATRICULA, 103)		[DATA_MATRICULA],
	PPESSOA.EMAIL											[EMAIL],
	PPESSOA.TELEFONE2										[TELEFONE]

FROM
	SPLETIVO
	INNER JOIN SMATRICPL ON
			SMATRICPL.IDPERLET = SPLETIVO.IDPERLET
	INNER JOIN SHABILITACAOFILIAL ON
			SHABILITACAOFILIAL.IDHABILITACAOFILIAL = SMATRICPL.IDHABILITACAOFILIAL
	INNER JOIN SSTATUS ON
			SSTATUS.CODSTATUS = SMATRICPL.CODSTATUS
	INNER JOIN SCURSO ON
			SCURSO.CODCURSO = SHABILITACAOFILIAL.CODCURSO
	INNER JOIN SALUNO ON
			SALUNO.RA = SMATRICPL.RA
	INNER JOIN PPESSOA ON
			PPESSOA.CODIGO = SALUNO.CODPESSOA

WHERE
		SPLETIVO.CODPERLET IN ('2019.1', '2019.2', '2020.1', '2020.2'
	--AND SMATRICPL.PERIODO = 1
	AND SSTATUS.CODSTATUS IN (12, 101, 111)
	--AND SMATRICPL.DTMATRICULA >= DATEADD(DAY,-3,GETDATE())

ORDER BY
	[DATA_MATRICULA],
	[ALUNO]