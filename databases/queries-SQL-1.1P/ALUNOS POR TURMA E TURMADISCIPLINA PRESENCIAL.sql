SELECT DISTINCT

	SDISCIPLINA.NOME AS 'DISCIPLINA',
	SALUNO.RA,
	ppessoa.nome as 'Aluno',
	STURMADISC.CODTURMA AS 'TURMA',
	SCURSO.NOME as 'Curso',
	ppessoa.EMAIL,
	ppessoa.TELEFONE2,
	ppessoa.TELEFONE1

FROM SPLETIVO (NOLOCK)
	INNER JOIN STURMADISC (NOLOCK) ON
			STURMADISC.CODCOLIGADA = SPLETIVO.CODCOLIGADA
		AND STURMADISC.CODFILIAL = SPLETIVO.CODFILIAL
		AND STURMADISC.IDPERLET = SPLETIVO.IDPERLET
	INNER JOIN SDISCIPLINA (NOLOCK) ON
			SDISCIPLINA.CODCOLIGADA = STURMADISC.CODCOLIGADA
		AND SDISCIPLINA.CODDISC = STURMADISC.CODDISC
	FULL OUTER JOIN STURMADISCGERENCIADA (NOLOCK) ON
			STURMADISCGERENCIADA.CODCOLIGADA = STURMADISC.CODCOLIGADA
		AND STURMADISCGERENCIADA.IDTURMADISCGERENCIADA = STURMADISC.IDTURMADISC
	FULL OUTER JOIN STURMADISC GERENCIAL (NOLOCK) ON
			GERENCIAL.CODCOLIGADA = STURMADISCGERENCIADA.CODCOLIGADA
		AND GERENCIAL.IDTURMADISC = STURMADISCGERENCIADA.IDTURMADISC
	FULL OUTER JOIN SDISCIPLINA DISCGERENC (NOLOCK) ON
			DISCGERENC.CODCOLIGADA = GERENCIAL.CODCOLIGADA
		AND DISCGERENC.CODDISC = GERENCIAL.CODDISC
	INNER JOIN SMATRICULA (NOLOCK) ON
			SMATRICULA.CODCOLIGADA = STURMADISC.CODCOLIGADA
		AND SMATRICULA.IDPERLET = STURMADISC.IDPERLET
		AND SMATRICULA.IDTURMADISC = STURMADISC.IDTURMADISC
	INNER JOIN SALUNO (NOLOCK) ON
			SALUNO.CODCOLIGADA = SMATRICULA.CODCOLIGADA
		AND SALUNO.RA = SMATRICULA.RA
	INNER JOIN PPESSOA (NOLOCK) ON
			PPESSOA.CODIGO = SALUNO.CODPESSOA
	INNER JOIN SHABILITACAOFILIAL ON
			SHABILITACAOFILIAL.CODCOLIGADA = STURMADISC.CODCOLIGADA
		AND SHABILITACAOFILIAL.IDHABILITACAOFILIAL = STURMADISC.IDHABILITACAOFILIAL
	INNER JOIN SCURSO (NOLOCK) ON
			SCURSO.CODCOLIGADA = SHABILITACAOFILIAL.CODCOLIGADA
		AND SCURSO.CODCURSO = SHABILITACAOFILIAL.CODCURSO
	INNER JOIN SMODALIDADECURSO (NOLOCK) ON
			SMODALIDADECURSO.CODCOLIGADA = SCURSO.CODCOLIGADA
		AND SMODALIDADECURSO.CODMODALIDADECURSO = SCURSO.CODMODALIDADECURSO

WHERE SPLETIVO.CODPERLET = '2021.2'
AND SMATRICULA.CODSTATUS = 19
AND SMODALIDADECURSO.CODMODALIDADECURSO = 1
and scurso.CODCURSO = 2

GROUP BY STURMADISC.CODTURMA, SDISCIPLINA.NOME,	GERENCIAL.CODTURMA, SALUNO.RA, SCURSO.NOME, ppessoa.NOME,ppessoa.EMAIL,ppessoa.TELEFONE2,ppessoa.TELEFONE1
