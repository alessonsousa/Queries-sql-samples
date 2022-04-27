SELECT DISTINCT

	scurso.CODCURSO,
	scurso.NOME,
	SMODALIDADECURSO.DESCRICAO,
	SMATRICPL.CODFILIAL


FROM SPLETIVO (NOLOCK)
	INNER JOIN SMATRICPL (NOLOCK) ON
			SMATRICPL.CODCOLIGADA = SPLETIVO.CODCOLIGADA
		AND SMATRICPL.CODFILIAL = SPLETIVO.CODFILIAL
		AND SMATRICPL.IDPERLET = SPLETIVO.IDPERLET
	INNER JOIN SMATRICULA (NOLOCK) ON
			SMATRICULA.CODCOLIGADA = SMATRICPL.CODCOLIGADA
		AND SMATRICULA.RA  = SMATRICPL.RA
	INNER JOIN SHABILITACAOFILIAL (NOLOCK) ON
			SHABILITACAOFILIAL.CODCOLIGADA = SMATRICPL.CODCOLIGADA
		AND SHABILITACAOFILIAL.IDHABILITACAOFILIAL = SMATRICPL.IDHABILITACAOFILIAL
	INNER JOIN SCURSO (NOLOCK) ON
			SCURSO.CODCOLIGADA = SHABILITACAOFILIAL.CODCOLIGADA
		AND SCURSO.CODCURSO = SHABILITACAOFILIAL.CODCURSO
	INNER JOIN SMODALIDADECURSO (NOLOCK) ON
			SMODALIDADECURSO.CODCOLIGADA = SCURSO.CODCOLIGADA
		AND SMODALIDADECURSO.CODMODALIDADECURSO = SCURSO.CODMODALIDADECURSO
	INNER JOIN SSTATUS STATUSPL (NOLOCK) ON
			STATUSPL.CODCOLIGADA = SMATRICPL.CODCOLIGADA
		AND STATUSPL.CODSTATUS = SMATRICPL.CODSTATUS
	INNER JOIN SALUNO (NOLOCK) ON
			SALUNO.RA = SMATRICPL.RA
	INNER JOIN PPESSOA (NOLOCK) ON
			PPESSOA.CODIGO = SALUNO.CODPESSOA
	INNER JOIN SGRADE (NOLOCK) ON
			SGRADE.CODCURSO = SCURSO.CODCURSO


WHERE SMATRICPL.CODCOLIGADA = 1
	AND SPLETIVO.CODPERLET IN ('2021.2')	

order by SCURSO.NOME
