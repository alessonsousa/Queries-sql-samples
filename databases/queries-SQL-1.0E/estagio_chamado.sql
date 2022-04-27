DECLARE @IDTURMADISC INT = (
SELECT
	IDTURMADISC
FROM 
	SESTAGIOCONTRATO
WHERE
		IDESTAGIOCONTRATO = 10		
	AND CODCOLIGADA = 1				
	AND RA = '2019110084'			
	)


DECLARE @ESTAGIOOBRIGATORIO VARCHAR(5) = (
SELECT
	ESTAGIOOBRIGATORIO
FROM 
	SESTAGIOCONTRATO
WHERE
		IDESTAGIOCONTRATO = 10		
	AND CODCOLIGADA = 1				
	AND RA = '2019110084'			
	)


DECLARE @CATEGORIA INT = (
SELECT
	CATEGORIA
FROM 
	SESTAGIOCONTRATO
	INNER JOIN SEMPRESA ON
			SEMPRESA.IDEMPRESA = SESTAGIOCONTRATO.IDEMPRESA
WHERE
		IDESTAGIOCONTRATO = 10		
	AND CODCOLIGADA = 1				
	AND RA = '2019110084'			
	)			


SELECT
	*
INTO 
	#CONSULTA1
FROM (
	SELECT
		*
	FROM (
		SELECT
			SEMPRESA.NOME				[NOME_EMPRESA],				
			SEMPRESA.NOMEFANTASIA		[NOMEFANTASIA_EMPRESA],		
			COALESCE(FUNCIONARIOS.CARTIDENTIDADE, '')	[CARTIDENTIDADE],
			COALESCE(FUNCIONARIOS.UFCARTIDENT, '')		[UFCARTIDENT],
			SEMPRESA.CEP				[CEP_EMPRESA],
			SEMPRESA.RUA				[RUA_EMPRESA],	
			CAST(SEMPRESA.NUMERO AS VARCHAR)				[NUMERO_EMPRESA],
			SEMPRESA.BAIRRO				[BAIRRO_EMPRESA],
			GMUNICIPIO.NOMEMUNICIPIO	[MUNICIPIO_EMPRESA],
			GMUNICIPIO.CODETDMUNICIPIO	[ESTADO_EMPRESA],
			SEMPRESA.CNPJ,
			SUPERVISOR.NOME				[SUPERVISOR],
			FUNCIONARIOS.NOME			[RESPONSAVEL],
			COALESCE(SUPERVISOR.CPF, '')				[CPF_SUPERVISOR],
			COALESCE(SUPERVISOR.TELEFONE, '')			[TEL_SUPERVISOR],
			COALESCE(SUPERVISOR.EMAIL, '')			[EMAIL_SUPERVISOR],
			COALESCE(SUPERVISOR.CARGO, '')			[CARGO_SUPERVISOR],
			SESTAGIOCONTRATO.IDESTAGIOCONTRATO	[IDESTAGIOCONTRATO_EMPRESA]
		FROM
			SESTAGIOCONTRATO (NOLOCK) 
		INNER JOIN SPLETIVO (NOLOCK) ON
				SPLETIVO.IDPERLET = SESTAGIOCONTRATO.IDPERLET
		INNER JOIN SMATRICPL (NOLOCK) ON
				SMATRICPL.RA = SESTAGIOCONTRATO.RA
			AND SMATRICPL.CODCOLIGADA = SESTAGIOCONTRATO.CODCOLIGADA
			AND SMATRICPL.IDHABILITACAOFILIAL = SESTAGIOCONTRATO.IDHABILITACAOFILIAL
			AND SMATRICPL.IDPERLET = SESTAGIOCONTRATO.IDPERLET
		INNER JOIN SEMPRESA (NOLOCK) ON
				SEMPRESA.IDEMPRESA = SESTAGIOCONTRATO.IDEMPRESA
		INNER JOIN SEMPRESAFUNCIONARIO SUPERVISOR (NOLOCK) ON
				SUPERVISOR.IDFUNCIONARIO = SESTAGIOCONTRATO.IDFUNCIONARIO
		LEFT JOIN SEMPRESAFUNCIONARIO FUNCIONARIOS (NOLOCK) ON
				FUNCIONARIOS.IDEMPRESA = SUPERVISOR.IDEMPRESA
			AND FUNCIONARIOS.FUNCAO IN (3, 4)
		INNER JOIN GMUNICIPIO (NOLOCK) ON
				GMUNICIPIO.CODMUNICIPIO = SEMPRESA.CODMUNICIPIO
			AND GMUNICIPIO.CODETDMUNICIPIO = SEMPRESA.ESTADO
		WHERE
				SESTAGIOCONTRATO.IDESTAGIOCONTRATO = 10		
			AND SESTAGIOCONTRATO.CODCOLIGADA = 1				
			AND SESTAGIOCONTRATO.RA = '2019110084'			
		) AS DADOS_EMPRESA

		INNER JOIN (
		SELECT 
			PPESSOA.NOME																											[ORIENTADOR],
			CONVERT(VARCHAR, CONVERT(INT, SESTAGIOCONTRATO.CHSEMANAL))																[CHSEMANAL],
			CONVERT(VARCHAR, SESTAGIOCONTRATO.HRINICIALEXPEDIENTE) 																	[HRINICIO],
			CONVERT(VARCHAR, SESTAGIOCONTRATO.HRFINALEXPEDIENTE)																	[HRFIM],
			CONVERT(VARCHAR(12), SESTAGIOCONTRATO.DTINICIOESTAGIO, 103)																[DTINICIOESTAGIO],
			CONVERT(VARCHAR(12), SESTAGIOCONTRATO.DTFINALESTAGIO, 103)																[DTFINALESTAGIO],
			CONVERT(VARCHAR, DATEDIFF(HOUR, CAST(SESTAGIOCONTRATO.HRINICIALEXPEDIENTE AS TIME), CAST(SESTAGIOCONTRATO.HRFINALEXPEDIENTE AS TIME))) AS [CHDIARIO],
			SESTAGIOCONTRATO.OBJETIVO																								[OBJETIVO],
			COALESCE(CAST(SESTAGIOCONTRATO.VLRBOLSA AS VARCHAR), '')																								[VLRBOLSA],
			COALESCE(CAST(SESTAGIOCONTRATO.VLRBENEFICIOS AS VARCHAR), '')																							[VLRBENEFICIOS],
			COALESCE(SESTAGIOAPOLICE.NOMECIASEGUROS, '')																							[NOMECIASEGUROS],
			COALESCE(CAST(SESTAGIOAPOLICE.NRAPOLICE AS VARCHAR), '')																								[NRAPOLICE],
			SESTAGIOCONTRATO.IDESTAGIOCONTRATO																						[IDESTAGIOCONTRATO_ESTAGIO]

		FROM
			SESTAGIOCONTRATO (NOLOCK)
			INNER JOIN SPLETIVO (NOLOCK) ON
					SPLETIVO.IDPERLET = SESTAGIOCONTRATO.IDPERLET
			LEFT JOIN SPROFESSOR (NOLOCK) ON
					SPROFESSOR.CODPROF = SESTAGIOCONTRATO.CODPROFORIENTADOR
			LEFT JOIN PPESSOA (NOLOCK) ON
					PPESSOA.CODIGO = 
					CASE 
						WHEN SPROFESSOR.CODPESSOA IS NULL THEN SESTAGIOCONTRATO.CODPESSOAORIENTADOR
						ELSE SPROFESSOR.CODPESSOA
					END
			LEFT JOIN SESTAGIOAPOLICE (NOLOCK) ON
					SESTAGIOAPOLICE.IDESTAGIOCONTRATO = SESTAGIOCONTRATO.IDESTAGIOCONTRATO
				AND SESTAGIOAPOLICE.RA = SESTAGIOCONTRATO.RA
		WHERE
				SESTAGIOCONTRATO.IDESTAGIOCONTRATO = 10		
			AND SESTAGIOCONTRATO.CODCOLIGADA = 1				
			AND SESTAGIOCONTRATO.RA = '2019110084'			
			) AS DADOS_ESTAGIO ON
					DADOS_ESTAGIO.IDESTAGIOCONTRATO_ESTAGIO = DADOS_EMPRESA.IDESTAGIOCONTRATO_EMPRESA

		INNER JOIN (
		SELECT 
			P_ALUNO.NOME					[ALUNO],
			SESTAGIOCONTRATO.RA				[MATRICULA_ALUNO],
			SCURSO.NOME						[CURSO_ALUNO],
			P_ALUNO.RUA						[RUA_ALUNO],
			P_ALUNO.NUMERO					[NUMERO_ALUNO],
			P_ALUNO.BAIRRO					[BAIRRO_ALUNO],
			P_ALUNO.CIDADE					[MUNICIPIO_ALUNO],
			P_ALUNO.ESTADO					[ESTADO_ALUNO],
			P_ALUNO.TELEFONE2				[TELEFONE_ALUNO],
			P_ALUNO.CPF						[CPF_ALUNO],
			STURNO.NOME 					[TURNO_ALUNO],
			CONVERT(VARCHAR, SMATRICPL.PERIODO)				[PERIODO_ALUNO],
			SESTAGIOCONTRATO.IDESTAGIOCONTRATO				[IDESTAGIOCONTRATO_ALUNO]
			
		FROM 
			SESTAGIOCONTRATO (NOLOCK)
			INNER JOIN SPLETIVO (NOLOCK) ON
					SPLETIVO.IDPERLET = SESTAGIOCONTRATO.IDPERLET
			INNER JOIN SALUNO (NOLOCK) ON
					SALUNO.RA = SESTAGIOCONTRATO.RA
			INNER JOIN PPESSOA P_ALUNO (NOLOCK) ON
					P_ALUNO.CODIGO = SALUNO.CODPESSOA
			INNER JOIN SHABILITACAOFILIAL (NOLOCK) ON
					SHABILITACAOFILIAL.IDHABILITACAOFILIAL = SESTAGIOCONTRATO.IDHABILITACAOFILIAL
			INNER JOIN SCURSO (NOLOCK) ON
					SCURSO.CODCURSO = SHABILITACAOFILIAL.CODCURSO
			INNER JOIN SMATRICPL (NOLOCK) ON
					SMATRICPL.IDPERLET = SESTAGIOCONTRATO.IDPERLET
				AND SMATRICPL.IDHABILITACAOFILIAL = SESTAGIOCONTRATO.IDHABILITACAOFILIAL
				AND SMATRICPL.RA = SESTAGIOCONTRATO.RA
			INNER JOIN STURNO (NOLOCK) ON
					STURNO.CODTURNO = SHABILITACAOFILIAL.CODTURNO
		WHERE
				SESTAGIOCONTRATO.IDESTAGIOCONTRATO = 10		
			AND SESTAGIOCONTRATO.CODCOLIGADA = 1				
			AND SESTAGIOCONTRATO.RA = '2019110084'			
			) AS DADOS_ALUNO ON
					DADOS_ALUNO.IDESTAGIOCONTRATO_ALUNO = DADOS_ESTAGIO.IDESTAGIOCONTRATO_ESTAGIO
	) AS CONSULTA


	
IF ((@IDTURMADISC IS NULL) AND (@ESTAGIOOBRIGATORIO = 'N' OR @ESTAGIOOBRIGATORIO IS NULL))
SELECT
	'TERMO DE COMPROMISSO DE ESTÁGIO NÃO OBRIGATÓRIO'
	AS TITULO,

	'Que entre si celebram, de um lado ' + #CONSULTA1.NOME_EMPRESA + ', situada à ' + #CONSULTA1.RUA_EMPRESA + ', ' + #CONSULTA1.NUMERO_EMPRESA + ', ' + #CONSULTA1.BAIRRO_EMPRESA + ', ' + #CONSULTA1.MUNICIPIO_EMPRESA + ', ' + #CONSULTA1.ESTADO_EMPRESA + ', com CNPJ ' + #CONSULTA1.CNPJ + ' doravante denominada simplesmente EMPRESA, neste ato representada pelo Sr(a) ' + #CONSULTA1.RESPONSAVEL + ', e de outro(a) aluno(a)  ' + #CONSULTA1.ALUNO + ', regularmente matriculado(a) no Curso de ' + #CONSULTA1.CURSO_ALUNO + ' do Centro Universitário Paraíso, semestre ' + #CONSULTA1.PERIODO_ALUNO + ', turno ' + #CONSULTA1.TURNO_ALUNO + ' doravante denominado(a) simplesmente ESTAGIÁRIO(A), residente ' + #CONSULTA1.RUA_ALUNO + ', ' + #CONSULTA1.NUMERO_ALUNO + ', ' + #CONSULTA1.BAIRRO_EMPRESA + ', ' + #CONSULTA1.MUNICIPIO_ALUNO + ', ' + #CONSULTA1.ESTADO_ALUNO + ', telefone ' + #CONSULTA1.TELEFONE_ALUNO + ', e contando com a interveniência da CENTRO UNIVERSITÁRIO PARAÍSO, instituição de ensino superior, com sede à Rua São Benedito, 344 – São Miguel – Juazeiro do Norte, Estado do Ceará, doravante denominada CENTRO UNIVERSITÁRIO PARAÍSO, neste ato representada por João Luís Alexandre Fiúsa, Reitor.'
	AS INTRO,

	'CLÁUSULA 1ª – DOS OBJETIVOS DO ESTÁGIO CURRICULAR SUPERVISIONADO'
	AS TITULO1,
	'I - proporcionar ao ESTAGIÁRIO atividades que visem ao aprendizado na sua área de formação possibilitando aliar a teoria à prática profissional;' + CHAR(10) +
	'II - possibilitar o desenvolvimento de competências próprias da atividade profissional e formação acadêmica do educando.'
	AS CLAUSULA1,

	'CLÁUSULA 2ª – DAS COMPETÊNCIAS DA EMPRESA'
	AS TITULO2,
	'I – designar supervisor de estágio que deverá ter formação ou experiência na área de atuação do ESTAGIÁRIO (A), respeitando o limite de supervisão de até 10(dez) estagiários simultaneamente;' + CHAR(10) +
	'II – proceder, a qualquer momento, mediante a indicação explicita das razões, o desligamento ou substituição do (a) ESTAGIÁRIO (A), dando ciência por escrito da ocorrência ao coordenador de estágio do CENTRO UNIVERSITÁRIO PARAÍSO;' + CHAR(10) +
	'III - possibilitar o acesso do(a) professor(a) orientador(a) pelo CENTRO UNIVERSITÁRIO PARAÍSO que visitará o local de estágio quando necessário;' + CHAR(10) +
	'IV – A empresa concederá bolsa-auxílio no valor de R$ ' + #CONSULTA1.VLRBOLSA + ' e R$ ' + #CONSULTA1.VLRBENEFICIOS + ' referente ao auxílio transporte.' + CHAR(10) +
	'V – O seguro contra acidentes pessoais em favor do estagiário foi realizado pela Seguradora ' + #CONSULTA1.NOMECIASEGUROS + ', cuja apólice é de nº ' + #CONSULTA1.NRAPOLICE + '.' + CHAR(10) +
	'VI – Reduzir a carga horária do estágio pelo menos à metade, no período de avaliações calendarizadas pela FACULDADE PARAÍSO, mediante comprovação através do Calendário Acadêmico;' + CHAR(10) +
	'VII – Assegurar ao estagiário, período de recesso remunerado de 30(trinta) dias, a ser gozado, preferencialmente, nos meses de janeiro ou julho, sempre que o estágio tenha duração igual ou superior a 1(um) ano.'
	AS CLAUSULA2,

	'CLÁUSULA 3ª – DAS COMPETÊNCIAS DO CENTRO UNIVERSITÁRIO'
	AS TITULO3,
	'I - Preparar, em nível preliminar, os (as) universitários (as) para o estágio;' + CHAR(10) +
	'II - Designar, como professor(a) orientador(a) o (a) Prof (a). ' + #CONSULTA1.ORIENTADOR + ' a quem caberá acompanhamento, orientação e avaliação do (a) ESTAGIÁRIO (A), bem como poderá visitar a EMPRESA conforme item III da Cláusula 2ª;' + CHAR(10) +
	'III - Manter atualizadas as informações cadastrais relativas ao Estagiário;' 
	AS CLAUSULA3,

	'CLÁUSULA 4ª - DAS COMPETÊNCIAS DO(A) ESTAGIÁRIO(A)'
	AS TITULO4,
	'I - estagiar durante 24 (vinte e quatro) meses, no máximo, num total de até 30 (trinta) horas semanais, sendo 6(seis) horas diárias;' + CHAR(10) +
	'II - realizar as tarefas previstas no seu Plano de Estágio e, na impossibilidade eventual do cumprimento de algum item dessa programação, comunicar por escrito ao Supervisor(a) da EMPRESA, para fins de aprovação ou não;' + CHAR(10) +
	'III - cumprir as normas da EMPRESA, principalmente as relativas ao estágio, que o ESTAGIÁRIO(A) declara expressamente conhecer;' + CHAR(10) +
	'IV - responder por perdas e danos consequentes da inobservância das normas internas, ou das constantes neste Termo de Compromisso seja por dolo ou culpa;' + CHAR(10) +
	'V - seguir a orientação do(a) supervisor(a) da EMPRESA e do(a) professor(a) orientador(a) designado pelo CENTRO UNIVERSITÁRIO PARAÍSO;' + CHAR(10) +
	'VI - apresentar os relatórios que lhe forem solicitados pela EMPRESA e pelo CENTRO UNIVERSITÁRIO PARAÍSO.' + CHAR(10) +
	'VII - cumprir a carga horária total de ' + #CONSULTA1.CHSEMANAL + ' horas, realizando o estágio no horário de ' + #CONSULTA1.HRINICIO + ' horas às ' + #CONSULTA1.HRFIM + ' horas, tendo como supervisor de estágio o Sr.(a) ' + #CONSULTA1.SUPERVISOR + ';' + CHAR(10) +
	'VIII - realizar as seguintes atividades: ' + #CONSULTA1.OBJETIVO + ';' + CHAR(10) +
	'IX - cumprir o estágio com vigência de ' + #CONSULTA1.DTINICIOESTAGIO + ' à ' + #CONSULTA1.DTFINALESTAGIO + '.'
	AS CLAUSULA4,

	'CLÁUSULA 5ª – DAS DISPOSIÇÕES GERAIS'
	AS TITULO5,
	'I - o(a) ESTAGIÁRIO(A) não terá, para quaisquer efeitos, vínculo empregatício com a EMPRESA, conforme o artigo 3º da Lei nº 11.788, de 25/09/2008.' + CHAR(10) +
	'Parágrafo único. E por estarem concordes, as partes signatárias deste instrumento elegem o foro do município de Juazeiro do Norte (CE) para dirimir eventuais pendências e subscrevem-no em três vias de igual teor, ficando uma via sob a guarda do ESTAGIÁRIO (A), outra com a EMPRESA e outra com o CENTRO UNIVERSITÁRIO PARAÍSO.'
	AS CLAUSULA5,

	NULL AS TITULO6,
	NULL AS CLAUSULA6,

	NULL AS TITULO7,
	NULL AS CLAUSULA7,

	NULL AS TITULO8,
	NULL AS CLAUSULA8,

	NULL AS TITULO9,
	NULL AS CLAUSULA9
FROM #CONSULTA1


ELSE IF ((@IDTURMADISC IS NOT NULL) AND (@ESTAGIOOBRIGATORIO = 'S') AND (@CATEGORIA = 5))
SELECT
	'TERMO DE COMPROMISSO DE ESTÁGIO OBRIGATÓRIO'
	AS TITULO,

	'O presente Termo de Compromisso de Estágio estabelece as condições básicas para realização do estágio, nos termos da Lei nº 11.788, de 25 de setembro de 2008, com vistas a promover a aprendizagem social, profissional e cultural no ambiente de trabalho. Firma-se este contrato entre a Concedente, a Instituição de Ensino e o Estagiário, cujos dados seguem abaixo:' + CHAR(10) +
	'Dados da(o) Concedente:' + CHAR(10) +
	'Nome do Profissional Liberal: ' + #CONSULTA1.NOME_EMPRESA + CHAR(10) + 
	'CPF: ' + #CONSULTA1.CPF_SUPERVISOR + CHAR(10) + 
	'Cargo: ' + #CONSULTA1.CARGO_SUPERVISOR + CHAR(10) + 
	'Nº do Registro Profissional: ' + #CONSULTA1.CNPJ + CHAR(10) + 
	'Endereço Completo: ' + #CONSULTA1.RUA_EMPRESA + ', ' + #CONSULTA1.NUMERO_EMPRESA + ', ' + #CONSULTA1.BAIRRO_EMPRESA + ', ' + #CONSULTA1.MUNICIPIO_EMPRESA + ', ' + #CONSULTA1.ESTADO_EMPRESA + CHAR(10) +
	'Telefone: ' + #CONSULTA1.TEL_SUPERVISOR + CHAR(10) +
	'E-mail: ' + #CONSULTA1.EMAIL_SUPERVISOR + CHAR(10) + CHAR(10) +

	'Dados da Instituição de Ensino:' + CHAR(10) +
	'CENTRO UNIVERSITÁRIO PARAÍSO' + CHAR(10) +
	'Endereço: Rua da Conceição, nº 344, bairro São Miguel, Juazeiro do Norte - CE - CEP: 63010-220' + CHAR(10) +
	'C.N.P.J.: 04.242.942/0001-37' + CHAR(10) +
	'Representante Legal: João Luis Alexandre Fiúsa  - Reitor do Centro Universitário Paraíso' + CHAR(10) + CHAR(10) +

	'Dados do Estagiário: ' + CHAR(10) +
	'Nome: ' + #CONSULTA1.ALUNO + CHAR(10) +
	'CPF: ' + #CONSULTA1.CPF_ALUNO + CHAR(10) +
	'Endereço Completo: ' + #CONSULTA1.RUA_ALUNO + ', ' + #CONSULTA1.NUMERO_ALUNO + ', ' + #CONSULTA1.BAIRRO_ALUNO + ', ' + #CONSULTA1.MUNICIPIO_ALUNO + ', ' + #CONSULTA1.ESTADO_ALUNO + CHAR(10) +
	'Telefone: ' + #CONSULTA1.TELEFONE_ALUNO + CHAR(10) +
	'Curso: ' + #CONSULTA1.CURSO_ALUNO + CHAR(10) + CHAR(10) +

	'Os acordantes acima citados têm entre si contratadas as seguintes condições gerais:'
	AS INTRO,

	'CLÁUSULA PRIMEIRA – DAS ATIVIDADES '
	AS TITULO1,
	'As atividades principais a serem desenvolvidas pelo ESTAGIÁRIO deverão ser pertinentes ao curso em que se encontra matriculado(a), sendo inadmissível desvios para funções inadequadas e estranhas à sua formação acadêmica.  De acordo com o Plano de Estágio anexo.' + CHAR(10) +
	'Supervisor de Estágio da CONCEDENTE: ' + #CONSULTA1.SUPERVISOR + CHAR(10) +
	'Formação Profissional/Cargo: ' + #CONSULTA1.CARGO_SUPERVISOR + CHAR(10) + 
	'Registro Profissional/Doc. de Identidade: ' + #CONSULTA1.CNPJ + CHAR(10) +
	'1.1.	As atividades descritas no plano de estágio poderão ser alteradas com o progresso do estágio e do currículo escolar, objetivando, sempre, a compatibilização e a complementação do curso.'
	AS CLAUSULA1,

	'CLÁUSULA SEGUNDA - DURAÇÃO E JORNADA'
	AS TITULO2,
	'2.1. A duração do estágio será de: ' + #CONSULTA1.DTINICIOESTAGIO + ' a ' + #CONSULTA1.DTFINALESTAGIO + ', podendo ou não ser prorrogado conforme entendimento entre as partes. A jornada de trabalho diária será de ' + #CONSULTA1.CHDIARIO + ' horas, em dias úteis com carga horária de ' + #CONSULTA1.CHSEMANAL + '(por extenso) horas semanais, de ' + #CONSULTA1.HRINICIO + ' às ' + #CONSULTA1.HRFIM + ' horas.' + CHAR(10) +  
	'2.2. Conforme dispõe o Art,1 da Lei nº 11.788/2008, a duração do estágio, na mesma parte concedente, não poderá exceder 2(dois) anos, exceto quando se tratar de estagiário portador de deficiência.' + CHAR(10) + 
	'2.3. A Carga horária do(a) estagiário(a) não poderá ultrapassar 6 (seis) horas diárias e 30 (trinta) horas semanais, conforme disposto no inciso II, art, 10 da Lei nº 11.788/2008.'
	AS CLAUSULA2,

	'CLÁUSULA TERCEIRA – DO SEGURO OBRIGATÓRIO'
	AS TITULO3,
	'3.1. Conforme dispõe o inciso IV, do Art. 9º da Lei nº 11.788/2008, o concedente se obriga a fazer a suas expensas, seguro de acidentes pessoais para cobertura de qualquer acidente que possa ocorrer com o estagiário durante a vigência do presente termo.'
	AS CLAUSULA3,

	'CLÁUSULA QUARTA – DA INEXISTÊNCIA DE VÍNCULO EMPREGATÍCIO'
	AS TITULO4,
	'Observadas as disposições previstas no art. 3º e   § 1º do art. 12 da Lei nº 11.788/2008.' + CHAR(10) + 
	'4.1. O estágio, tanto obrigatório quanto o não obrigatório, não cria vinculo empregatício de qualquer natureza.' + CHAR(10) +
	'4.2. A eventual concessão de benefícios relacionados a Transporte, alimentação e saúde, entre outros, não caracteriza vínculo empregatício.'
	AS CLAUSULA4,

	'CLÁUSULA QUINTA - DAS COMPETÊNCIAS DO(A) ESTAGIÁRIO(A)'
	AS TITULO5,
	'5.1. Estagiar, com periodicidade máxima de, 24 (vinte e quatro) meses, 30 (trinta) horas semanais, sendo 6(seis) horas diárias.' + CHAR(10) +
	'5.2. Realizar as tarefas previstas no seu Plano de Estágio e, na impossibilidade eventual do cumprimento de algum item dessa programação, comunicar por escrito ao Supervisor(a) da CONCEDENTE e Professor(a) orientador(a), para fins de aprovação ou não.' + CHAR(10) +
	'5.3. Cumprir as normas da CONCEDENTE, principalmente as relativas ao Estágio, que o ESTAGIÁRIO(A) declara expressamente conhecer.' + CHAR(10) +
	'5.4. Responder por perdas e danos consequentes da inobservância das normas internas ou das constantes neste Termo de Compromisso, seja por dolo ou culpa.' + CHAR(10)
	AS CLAUSULA5,

	'CLÁUSULA SEXTA – DAS COMPETÊNCIAS DO PROFISSIONAL LIBERAL'
	AS TITULO6,
	'6.1. Oportunizar as tarefas que serão desenvolvidas pelo ESTAGIÁRIO (A), de acordo com os objetivos da disciplina de estágio que o aluno está cursando.' + CHAR(10) +
	'6.2. Designar Supervisor de estágio a quem competirá articular-se com o(a) professor(a) orientador(a) de estágio especificado pelo CENTRO UNIVERSITÁRIO PARAÍSO, respeitando o limite de até 10(dez) estagiários simultaneamente;' + CHAR(10) +
	'6.3. O supervisor da CONCEDENTE sempre que possível, deverá ter conhecimento ou vivência na área de atuação do ESTAGIÁRIO (A);' + CHAR(10) +
	'6.5. Possibilitar o acesso do(a) Professor(a) orientador(a) designado(a) pelo CENTRO UNIVERSITÁRIO PARAÍSO que visitará o local de estágio quando necessário;' + CHAR(10) +
	'6.6. Realizar a avaliação do estagiário através de formulários específicos propostos pelo CENTRO UNIVERSITÁRIO PARAÍSO;' + CHAR(10) +
	'6.7. Assinar os formulários de acompanhamento e avaliação do estagiário para fins de comprovação.' + CHAR(10) 
	AS CLAUSULA6,

	'CLÁUSULA SÉTIMA – DAS COMPETÊNCIAS DA CENTRO UNIVERSITÁRIO'
	AS TITULO7,
	'7.1. Preparar, em nível preliminar, os (as) universitários (as) para o Estágio.' + CHAR(10) +
	'7.2. Designar, como orientador (a) o Prof (a). ' + #CONSULTA1.ORIENTADOR + ' a quem caberá acompanhamento, orientação e avaliação do (a) ESTAGIÁRIO (A), bem como poderá visitar a CONCEDENTE.' + CHAR(10) +
	'7.3. Manter atualizadas as informações cadastrais relativas ao Estágio.' + CHAR(10) +
	'7.4. Providenciar o seguro obrigatório contra acidentes pessoais em favor do estagiário.' + CHAR(10)
	AS CLAUSULA7,

	'CLÁUSULA OITAVA – DA RESCISÃO'
	AS TITULO8,
	'8.1.	Não cumprimento do convencionado nas cláusulas do Termo de Compromisso de Estágio.' + CHAR(10) +
	'8.2.	Automaticamente, no término do prazo previsto no Termo de Compromisso de Estágio.' + CHAR(10) +
	'8.3.	Trancamento da matrícula, conclusão, abandono do curso (desistência) e infrequência.' + CHAR(10) +
	'8.4.	Contratação em regime de CLT.' + CHAR(10) +
	'8.5.	Interesse e conveniência do (a) CONCEDENTE.' + CHAR(10) +
	'8.6.	Interesses particulares do estagiário.' + CHAR(10) +
	'8.7.	Serem atribuídas ao (a) estagiário (a) atividades reconhecidamente incompatíveis com sua habilitação ou formação.' + CHAR(10) +
	'8.8.	Não comparecimento ao local do estágio, sem motivo justificado, por 5 (cinco) dias consecutivos ou 12 (doze) dias alternados, no período de um mês.' + CHAR(10) +
	'8.9.	Não cumprimento da cláusula 4ª deste presente Termo de Compromisso de Estágio.' + CHAR(10)
	AS CLAUSULA8,

	'CLÁUSULA NONA – DAS DISPOSIÇÕES GERAIS'
	AS TITULO9,
	'9.1. O (a) ESTAGIÁRIO(A), cumpridas as cláusulas acima, para quaisquer efeitos, não terá vínculo empregatício com a CONCEDENTE, conforme o artigo 3º da Lei nº 11.788, de 25/09/2008.' + CHAR(10) +
	'Parágrafo único: E por estarem concordes, as partes signatárias deste instrumento elegem o foro da cidade de Juazeiro do Norte (CE) para dirimir eventuais pendências e subscrevem-no em três vias de igual teor, ficando uma cópia sob a guarda do ESTAGIÁRIO (A), outra com a CONCEDENTE e outra com o CENTRO UNIVERSITÁRIO PARAÍSO.'
	AS CLAUSULA9
FROM #CONSULTA1


ELSE IF ((@IDTURMADISC IS NOT NULL) AND (@ESTAGIOOBRIGATORIO = 'S') AND (@CATEGORIA <> 5))
SELECT
	'TERMO DE COMPROMISSO DE ESTÁGIO OBRIGATÓRIO'
	AS TITULO,

	'Que entre si celebram, de um lado ' + #CONSULTA1.NOME_EMPRESA + ', situada à ' + #CONSULTA1.RUA_EMPRESA + ', ' + #CONSULTA1.NUMERO_EMPRESA + ', ' + #CONSULTA1.BAIRRO_EMPRESA + ', ' + #CONSULTA1.MUNICIPIO_EMPRESA + ', ' + #CONSULTA1.ESTADO_EMPRESA + ', nesta cidade, com CNPJ: ' + #CONSULTA1.CNPJ + ' doravante denominada simplesmente EMPRESA, neste ato representada pelo Sr(a) ' + #CONSULTA1.RESPONSAVEL + ', e de outro o(a) aluno(a) ' + #CONSULTA1.ALUNO + ', regularmente matriculado(a) no Curso de ' + #CONSULTA1.CURSO_ALUNO + ' do Centro Universitário Paraíso, doravante denominado(a) simplesmente ESTAGIÁRIO(A), residente ' + #CONSULTA1.RUA_ALUNO + ', ' + #CONSULTA1.NUMERO_ALUNO + ', ' + #CONSULTA1.BAIRRO_ALUNO + ', ' + #CONSULTA1.MUNICIPIO_ALUNO + ', ' + #CONSULTA1.ESTADO_ALUNO + ', telefone ' + #CONSULTA1.TELEFONE_ALUNO + ', e contando com a interveniência do CENTRO UNIVERSITÁRIO PARAÍSO, instituição de ensino superior, com sede à Rua São Benedito, 344 – São Miguel – Juazeiro do Norte, Estado do Ceará, doravante denominado CENTRO UNIVERSITÁRIO PARAÍSO, neste ato representada por João Luis Alexandre Fiúsa, Reitor.'
	AS INTRO,

	'CLÁUSULA 1ª – DOS OBJETIVOS DO ESTÁGIO CURRICULAR SUPERVISIONADO'
	AS TITULO1,
	'I - proporcionar ao ESTAGIÁRIO atividades que visem ao aprendizado na sua área de formação acadêmica possibilitando aliar a teoria à prática profissional;' + CHAR(10) + 'II - possibilitar à CENTRO UNIVERSITÁRIO PARAÍSO mais de um caminho para a obtenção de subsídios necessários à atualização de seus currículos, bem como à EMPRESA mais um canal de informações indispensáveis à constante aproximação das fontes de conhecimentos técnicos e científicos.'
	AS CLAUSULA1,

	'CLÁUSULA 2ª – DAS COMPETÊNCIAS DA EMPRESA'
	AS TITULO2,
	'I- oportunizar as tarefas que serão desenvolvidas pelo ESTAGIÁRIO (A), de acordo com os objetivos da disciplina de estágio que o aluno está cursando;' + CHAR(10) +
	'II- designar Supervisor de estágio na empresa, a quem competirá articular-se com o(a) Professor(a) orientador(a) de estágio especificado pelo CENTRO UNIVERSITÁRIO PARAÍSO, respeitando o limite de até 10(dez) estagiários simultaneamente;' + CHAR(10) +
	'III - o supervisor da EMPRESA sempre que possível, deverá ter conhecimento ou vivência na área de atuação do ESTAGIÁRIO (A);' + CHAR(10) +
	'IV - possibilitar o acesso do(a) Professor(a) orientador(a) designado(a) pelo CENTRO UNIVERSITÁRIO PARAÍSO que visitará o local de estágio quando necessário;' + CHAR(10) +
	'V – realizar a avaliação do estagiário através de formulários específicos propostos pelo CENTRO UNIVERSITÁRIO PARAÍSO;' + CHAR(10) +
	'VI – assinar os formulários de acompanhamento e avaliação do estagiário para fins de comprovação.'
	AS CLAUSULA2,

	'CLÁUSULA 3ª – DAS COMPETÊNCIAS DO CENTRO UNIVERSITÁRIO'
	AS TITULO3,
	'I - preparar, em nível preliminar, os (as) universitários (as) para o Estágio;' + CHAR(10) + 
	'II - designar, como orientador (a) o Prof (a).' + #CONSULTA1.ORIENTADOR + ' a quem caberá acompanhamento, orientação e avaliação do (a) ESTAGIÁRIO (A), bem como poderá visitar a EMPRESA;' + CHAR(10) + 
	'III - manter atualizadas as informações cadastrais relativas ao Estágio;' + CHAR(10) + 
	'IV - providenciar o seguro obrigatório contra acidentes pessoais em favor do estagiário;'
	AS CLAUSULA3,

	'CLÁUSULA 4ª - DAS COMPETÊNCIAS DO(A) ESTAGIÁRIO(A)'
	AS TITULO4,
	'I – estagiar, com periodicidade máxima de, 24 (vinte e quatro) meses, 30 (trinta) horas semanais, sendo 6(seis) horas diárias;' + CHAR(10) + 
	'II - realizar as tarefas previstas no seu Plano de Estágio e, na impossibilidade eventual do cumprimento de algum item dessa programação, comunicar por escrito ao Supervisor(a) da EMPRESA e Professor(a) orientador(a), para fins de aprovação ou não;' + CHAR(10) + 
	'III - cumprir as normas da EMPRESA, principalmente as relativas ao Estágio, que o ESTAGIÁRIO(A) declara expressamente conhecer;' + CHAR(10) + 
	'IV - responder por perdas e danos consequentes da inobservância das normas internas ou das constantes neste Termo de Compromisso seja por dolo ou culpa;' + CHAR(10) + 
	'V - seguir a orientação do Supervisor(a) da EMPRESA e do(a) professor(a)  Orientador(a) designado pelo CENTRO UNIVERSITÁRIO PARAÍSO;' + CHAR(10) + 
	'VI- apresentar os relatórios que lhe forem solicitados pela EMPRESA e pelo CENTRO UNIVERSITÁRIO PARAÍSO, observando os prazos estabelecidos;' + CHAR(10) + 
	'VII- cumprir a carga horária total de ' + #CONSULTA1.CHSEMANAL + ' horas, realizando o estágio no horário de ' + #CONSULTA1.HRINICIO + ' horas a ' + #CONSULTA1.HRFIM + ' horas, tendo como supervisor técnico o Sr.(a) ' + #CONSULTA1.SUPERVISOR + ';' + CHAR(10) + 
	'VIII - realizar as seguintes atividades: ' + #CONSULTA1.OBJETIVO + ';' + CHAR(10) + 
	'IX - cumprir o estágio no período de ' + #CONSULTA1.DTINICIOESTAGIO + ' a ' + #CONSULTA1.DTFINALESTAGIO + '.'
	AS CLAUSULA4,

	'CLÁUSULA 5ª – DAS DISPOSIÇÕES GERAIS'
	AS TITULO5,
	'I - o (a) ESTAGIÁRIO(A) cumprido as cláusulas acima, para quaisquer efeitos, não terá vínculo empregatício com a EMPRESA, conforme o artigo 3º da Lei nº 11.788, de 25/09/2008.' + CHAR(10) +
	'Parágrafo único: E por estarem concordes, as partes signatárias deste instrumento elegem o foro da cidade de Juazeiro do Norte (CE) para dirimir eventuais pendências e subscrevem-no em três vias de igual teor, ficando uma cópia sob a guarda do ESTAGIÁRIO (A), outra com a EMPRESA e outra com a CENTRO UNIVERSITÁRIO PARAÍSO.'
	AS CLAUSULA5,

	NULL AS TITULO6,
	NULL AS CLAUSULA6,

	NULL AS TITULO7,
	NULL AS CLAUSULA7,

	NULL AS TITULO8,
	NULL AS CLAUSULA8,

	NULL AS TITULO9,
	NULL AS CLAUSULA9
FROM #CONSULTA1


DROP TABLE #CONSULTA1

