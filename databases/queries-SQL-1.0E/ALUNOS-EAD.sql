SELECT
	SMATRICPL.RA									[MATRICULA],
	UPPER(PPESSOA.NOME)									[ALUNO],
	CONVERT(VARCHAR, SMATRICPL.DTMATRICULA, 103)	[DTMATRICULA],
	SCURSO.NOME										[CURSO],
	SMODALIDADECURSO.DESCRICAO						[MODALIDADE]

FROM SMATRICPL
	INNER JOIN SALUNO ON
			SALUNO.RA = SMATRICPL.RA
	INNER JOIN PPESSOA ON
			PPESSOA.CODIGO = SALUNO.CODPESSOA
	INNER JOIN SHABILITACAOFILIAL ON
			SHABILITACAOFILIAL.IDHABILITACAOFILIAL = SMATRICPL.IDHABILITACAOFILIAL
	INNER JOIN SCURSO ON
			SCURSO.CODCURSO = SHABILITACAOFILIAL.CODCURSO
	INNER JOIN SMODALIDADECURSO ON
			SMODALIDADECURSO.CODMODALIDADECURSO = SCURSO.CODMODALIDADECURSO

WHERE
		SMATRICPL.DTMATRICULA BETWEEN CONVERT(DATETIME, '2021-01-07') AND CONVERT(DATETIME, '2021-05-07')
	AND SMODALIDADECURSO.CODMODALIDADECURSO IN (2, 3)
	AND SMATRICPL.CODSTATUS IN (12, 101, 111)

ORDER BY
		SMATRICPL.DTMATRICULA, [ALUNO]