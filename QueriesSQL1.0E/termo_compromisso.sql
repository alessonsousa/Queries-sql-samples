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
	'TERMO DE COMPROMISSO DE EST�GIO N�O OBRIGAT�RIO'
	AS TITULO,

	'Que entre si celebram, de um lado ' + #CONSULTA1.NOME_EMPRESA + ', situada � ' + #CONSULTA1.RUA_EMPRESA + ', ' + #CONSULTA1.NUMERO_EMPRESA + ', ' + #CONSULTA1.BAIRRO_EMPRESA + ', ' + #CONSULTA1.MUNICIPIO_EMPRESA + ', ' + #CONSULTA1.ESTADO_EMPRESA + ', com CNPJ ' + #CONSULTA1.CNPJ + ' doravante denominada simplesmente EMPRESA, neste ato representada pelo Sr(a) ' + #CONSULTA1.RESPONSAVEL + ', e de outro(a) aluno(a)  ' + #CONSULTA1.ALUNO + ', regularmente matriculado(a) no Curso de ' + #CONSULTA1.CURSO_ALUNO + ' do Centro Universit�rio Para�so, semestre ' + #CONSULTA1.PERIODO_ALUNO + ', turno ' + #CONSULTA1.TURNO_ALUNO + ' doravante denominado(a) simplesmente ESTAGI�RIO(A), residente ' + #CONSULTA1.RUA_ALUNO + ', ' + #CONSULTA1.NUMERO_ALUNO + ', ' + #CONSULTA1.BAIRRO_EMPRESA + ', ' + #CONSULTA1.MUNICIPIO_ALUNO + ', ' + #CONSULTA1.ESTADO_ALUNO + ', telefone ' + #CONSULTA1.TELEFONE_ALUNO + ', e contando com a interveni�ncia da CENTRO UNIVERSIT�RIO PARA�SO, institui��o de ensino superior, com sede � Rua S�o Benedito, 344 � S�o Miguel � Juazeiro do Norte, Estado do Cear�, doravante denominada CENTRO UNIVERSIT�RIO PARA�SO, neste ato representada por Jo�o Lu�s Alexandre Fi�sa, Reitor.'
	AS INTRO,

	'CL�USULA 1� � DOS OBJETIVOS DO EST�GIO CURRICULAR SUPERVISIONADO'
	AS TITULO1,
	'I - proporcionar ao ESTAGI�RIO atividades que visem ao aprendizado na sua �rea de forma��o possibilitando aliar a teoria � pr�tica profissional;' + CHAR(10) +
	'II - possibilitar o desenvolvimento de compet�ncias pr�prias da atividade profissional e forma��o acad�mica do educando.'
	AS CLAUSULA1,

	'CL�USULA 2� � DAS COMPET�NCIAS DA EMPRESA'
	AS TITULO2,
	'I � designar supervisor de est�gio que dever� ter forma��o ou experi�ncia na �rea de atua��o do ESTAGI�RIO (A), respeitando o limite de supervis�o de at� 10(dez) estagi�rios simultaneamente;' + CHAR(10) +
	'II � proceder, a qualquer momento, mediante a indica��o explicita das raz�es, o desligamento ou substitui��o do (a) ESTAGI�RIO (A), dando ci�ncia por escrito da ocorr�ncia ao coordenador de est�gio do CENTRO UNIVERSIT�RIO PARA�SO;' + CHAR(10) +
	'III - possibilitar o acesso do(a) professor(a) orientador(a) pelo CENTRO UNIVERSIT�RIO PARA�SO que visitar� o local de est�gio quando necess�rio;' + CHAR(10) +
	'IV � A empresa conceder� bolsa-aux�lio no valor de R$ ' + #CONSULTA1.VLRBOLSA + ' e R$ ' + #CONSULTA1.VLRBENEFICIOS + ' referente ao aux�lio transporte.' + CHAR(10) +
	'V � O seguro contra acidentes pessoais em favor do estagi�rio foi realizado pela Seguradora ' + #CONSULTA1.NOMECIASEGUROS + ', cuja ap�lice � de n� ' + #CONSULTA1.NRAPOLICE + '.' + CHAR(10) +
	'VI � Reduzir a carga hor�ria do est�gio pelo menos � metade, no per�odo de avalia��es calendarizadas pela FACULDADE PARA�SO, mediante comprova��o atrav�s do Calend�rio Acad�mico;' + CHAR(10) +
	'VII � Assegurar ao estagi�rio, per�odo de recesso remunerado de 30(trinta) dias, a ser gozado, preferencialmente, nos meses de janeiro ou julho, sempre que o est�gio tenha dura��o igual ou superior a 1(um) ano.'
	AS CLAUSULA2,

	'CL�USULA 3� � DAS COMPET�NCIAS DO CENTRO UNIVERSIT�RIO'
	AS TITULO3,
	'I - Preparar, em n�vel preliminar, os (as) universit�rios (as) para o est�gio;' + CHAR(10) +
	'II - Designar, como professor(a) orientador(a) o (a) Prof (a). ' + #CONSULTA1.ORIENTADOR + ' a quem caber� acompanhamento, orienta��o e avalia��o do (a) ESTAGI�RIO (A), bem como poder� visitar a EMPRESA conforme item III da Cl�usula 2�;' + CHAR(10) +
	'III - Manter atualizadas as informa��es cadastrais relativas ao Estagi�rio;' 
	AS CLAUSULA3,

	'CL�USULA 4� - DAS COMPET�NCIAS DO(A) ESTAGI�RIO(A)'
	AS TITULO4,
	'I - estagiar durante 24 (vinte e quatro) meses, no m�ximo, num total de at� 30 (trinta) horas semanais, sendo 6(seis) horas di�rias;' + CHAR(10) +
	'II - realizar as tarefas previstas no seu Plano de Est�gio e, na impossibilidade eventual do cumprimento de algum item dessa programa��o, comunicar por escrito ao Supervisor(a) da EMPRESA, para fins de aprova��o ou n�o;' + CHAR(10) +
	'III - cumprir as normas da EMPRESA, principalmente as relativas ao est�gio, que o ESTAGI�RIO(A) declara expressamente conhecer;' + CHAR(10) +
	'IV - responder por perdas e danos consequentes da inobserv�ncia das normas internas, ou das constantes neste Termo de Compromisso seja por dolo ou culpa;' + CHAR(10) +
	'V - seguir a orienta��o do(a) supervisor(a) da EMPRESA e do(a) professor(a) orientador(a) designado pelo CENTRO UNIVERSIT�RIO PARA�SO;' + CHAR(10) +
	'VI - apresentar os relat�rios que lhe forem solicitados pela EMPRESA e pelo CENTRO UNIVERSIT�RIO PARA�SO.' + CHAR(10) +
	'VII - cumprir a carga hor�ria total de ' + #CONSULTA1.CHSEMANAL + ' horas, realizando o est�gio no hor�rio de ' + #CONSULTA1.HRINICIO + ' horas �s ' + #CONSULTA1.HRFIM + ' horas, tendo como supervisor de est�gio o Sr.(a) ' + #CONSULTA1.SUPERVISOR + ';' + CHAR(10) +
	'VIII - realizar as seguintes atividades: ' + #CONSULTA1.OBJETIVO + ';' + CHAR(10) +
	'IX - cumprir o est�gio com vig�ncia de ' + #CONSULTA1.DTINICIOESTAGIO + ' � ' + #CONSULTA1.DTFINALESTAGIO + '.'
	AS CLAUSULA4,

	'CL�USULA 5� � DAS DISPOSI��ES GERAIS'
	AS TITULO5,
	'I - o(a) ESTAGI�RIO(A) n�o ter�, para quaisquer efeitos, v�nculo empregat�cio com a EMPRESA, conforme o artigo 3� da Lei n� 11.788, de 25/09/2008.' + CHAR(10) +
	'Par�grafo �nico. E por estarem concordes, as partes signat�rias deste instrumento elegem o foro do munic�pio de Juazeiro do Norte (CE) para dirimir eventuais pend�ncias e subscrevem-no em tr�s vias de igual teor, ficando uma via sob a guarda do ESTAGI�RIO (A), outra com a EMPRESA e outra com o CENTRO UNIVERSIT�RIO PARA�SO.'
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
	'TERMO DE COMPROMISSO DE EST�GIO OBRIGAT�RIO'
	AS TITULO,

	'O presente Termo de Compromisso de Est�gio estabelece as condi��es b�sicas para realiza��o do est�gio, nos termos da Lei n� 11.788, de 25 de setembro de 2008, com vistas a promover a aprendizagem social, profissional e cultural no ambiente de trabalho. Firma-se este contrato entre a Concedente, a Institui��o de Ensino e o Estagi�rio, cujos dados seguem abaixo:' + CHAR(10) +
	'Dados da(o) Concedente:' + CHAR(10) +
	'Nome do Profissional Liberal: ' + #CONSULTA1.NOME_EMPRESA + CHAR(10) + 
	'CPF: ' + #CONSULTA1.CPF_SUPERVISOR + CHAR(10) + 
	'Cargo: ' + #CONSULTA1.CARGO_SUPERVISOR + CHAR(10) + 
	'N� do Registro Profissional: ' + #CONSULTA1.CNPJ + CHAR(10) + 
	'Endere�o Completo: ' + #CONSULTA1.RUA_EMPRESA + ', ' + #CONSULTA1.NUMERO_EMPRESA + ', ' + #CONSULTA1.BAIRRO_EMPRESA + ', ' + #CONSULTA1.MUNICIPIO_EMPRESA + ', ' + #CONSULTA1.ESTADO_EMPRESA + CHAR(10) +
	'Telefone: ' + #CONSULTA1.TEL_SUPERVISOR + CHAR(10) +
	'E-mail: ' + #CONSULTA1.EMAIL_SUPERVISOR + CHAR(10) + CHAR(10) +

	'Dados da Institui��o de Ensino:' + CHAR(10) +
	'CENTRO UNIVERSIT�RIO PARA�SO' + CHAR(10) +
	'Endere�o: Rua da Concei��o, n� 344, bairro S�o Miguel, Juazeiro do Norte - CE - CEP: 63010-220' + CHAR(10) +
	'C.N.P.J.: 04.242.942/0001-37' + CHAR(10) +
	'Representante Legal: Jo�o Luis Alexandre Fi�sa  - Reitor do Centro Universit�rio Para�so' + CHAR(10) + CHAR(10) +

	'Dados do Estagi�rio: ' + CHAR(10) +
	'Nome: ' + #CONSULTA1.ALUNO + CHAR(10) +
	'CPF: ' + #CONSULTA1.CPF_ALUNO + CHAR(10) +
	'Endere�o Completo: ' + #CONSULTA1.RUA_ALUNO + ', ' + #CONSULTA1.NUMERO_ALUNO + ', ' + #CONSULTA1.BAIRRO_ALUNO + ', ' + #CONSULTA1.MUNICIPIO_ALUNO + ', ' + #CONSULTA1.ESTADO_ALUNO + CHAR(10) +
	'Telefone: ' + #CONSULTA1.TELEFONE_ALUNO + CHAR(10) +
	'Curso: ' + #CONSULTA1.CURSO_ALUNO + CHAR(10) + CHAR(10) +

	'Os acordantes acima citados t�m entre si contratadas as seguintes condi��es gerais:'
	AS INTRO,

	'CL�USULA PRIMEIRA � DAS ATIVIDADES '
	AS TITULO1,
	'As atividades principais a serem desenvolvidas pelo ESTAGI�RIO dever�o ser pertinentes ao curso em que se encontra matriculado(a), sendo inadmiss�vel desvios para fun��es inadequadas e estranhas � sua forma��o acad�mica.  De acordo com o Plano de Est�gio anexo.' + CHAR(10) +
	'Supervisor de Est�gio da CONCEDENTE: ' + #CONSULTA1.SUPERVISOR + CHAR(10) +
	'Forma��o Profissional/Cargo: ' + #CONSULTA1.CARGO_SUPERVISOR + CHAR(10) + 
	'Registro Profissional/Doc. de Identidade: ' + #CONSULTA1.CNPJ + CHAR(10) +
	'1.1.	As atividades descritas no plano de est�gio poder�o ser alteradas com o progresso do est�gio e do curr�culo escolar, objetivando, sempre, a compatibiliza��o e a complementa��o do curso.'
	AS CLAUSULA1,

	'CL�USULA SEGUNDA - DURA��O E JORNADA'
	AS TITULO2,
	'2.1. A dura��o do est�gio ser� de: ' + #CONSULTA1.DTINICIOESTAGIO + ' a ' + #CONSULTA1.DTFINALESTAGIO + ', podendo ou n�o ser prorrogado conforme entendimento entre as partes. A jornada de trabalho di�ria ser� de ' + #CONSULTA1.CHDIARIO + ' horas, em dias �teis com carga hor�ria de ' + #CONSULTA1.CHSEMANAL + '(por extenso) horas semanais, de ' + #CONSULTA1.HRINICIO + ' �s ' + #CONSULTA1.HRFIM + ' horas.' + CHAR(10) +  
	'2.2. Conforme disp�e o Art,1 da Lei n� 11.788/2008, a dura��o do est�gio, na mesma parte concedente, n�o poder� exceder 2(dois) anos, exceto quando se tratar de estagi�rio portador de defici�ncia.' + CHAR(10) + 
	'2.3. A Carga hor�ria do(a) estagi�rio(a) n�o poder� ultrapassar 6 (seis) horas di�rias e 30 (trinta) horas semanais, conforme disposto no inciso II, art, 10 da Lei n� 11.788/2008.'
	AS CLAUSULA2,

	'CL�USULA TERCEIRA � DO SEGURO OBRIGAT�RIO'
	AS TITULO3,
	'3.1. Conforme disp�e o inciso IV, do Art. 9� da Lei n� 11.788/2008, o concedente se obriga a fazer a suas expensas, seguro de acidentes pessoais para cobertura de qualquer acidente que possa ocorrer com o estagi�rio durante a vig�ncia do presente termo.'
	AS CLAUSULA3,

	'CL�USULA QUARTA � DA INEXIST�NCIA DE V�NCULO EMPREGAT�CIO'
	AS TITULO4,
	'Observadas as disposi��es previstas no art. 3� e   � 1� do art. 12 da Lei n� 11.788/2008.' + CHAR(10) + 
	'4.1. O est�gio, tanto obrigat�rio quanto o n�o obrigat�rio, n�o cria vinculo empregat�cio de qualquer natureza.' + CHAR(10) +
	'4.2. A eventual concess�o de benef�cios relacionados a Transporte, alimenta��o e sa�de, entre outros, n�o caracteriza v�nculo empregat�cio.'
	AS CLAUSULA4,

	'CL�USULA QUINTA - DAS COMPET�NCIAS DO(A) ESTAGI�RIO(A)'
	AS TITULO5,
	'5.1. Estagiar, com periodicidade m�xima de, 24 (vinte e quatro) meses, 30 (trinta) horas semanais, sendo 6(seis) horas di�rias.' + CHAR(10) +
	'5.2. Realizar as tarefas previstas no seu Plano de Est�gio e, na impossibilidade eventual do cumprimento de algum item dessa programa��o, comunicar por escrito ao Supervisor(a) da CONCEDENTE e Professor(a) orientador(a), para fins de aprova��o ou n�o.' + CHAR(10) +
	'5.3. Cumprir as normas da CONCEDENTE, principalmente as relativas ao Est�gio, que o ESTAGI�RIO(A) declara expressamente conhecer.' + CHAR(10) +
	'5.4. Responder por perdas e danos consequentes da inobserv�ncia das normas internas ou das constantes neste Termo de Compromisso, seja por dolo ou culpa.' + CHAR(10)
	AS CLAUSULA5,

	'CL�USULA SEXTA � DAS COMPET�NCIAS DO PROFISSIONAL LIBERAL'
	AS TITULO6,
	'6.1. Oportunizar as tarefas que ser�o desenvolvidas pelo ESTAGI�RIO (A), de acordo com os objetivos da disciplina de est�gio que o aluno est� cursando.' + CHAR(10) +
	'6.2. Designar Supervisor de est�gio a quem competir� articular-se com o(a) professor(a) orientador(a) de est�gio especificado pelo CENTRO UNIVERSIT�RIO PARA�SO, respeitando o limite de at� 10(dez) estagi�rios simultaneamente;' + CHAR(10) +
	'6.3. O supervisor da CONCEDENTE sempre que poss�vel, dever� ter conhecimento ou viv�ncia na �rea de atua��o do ESTAGI�RIO (A);' + CHAR(10) +
	'6.5. Possibilitar o acesso do(a) Professor(a) orientador(a) designado(a) pelo CENTRO UNIVERSIT�RIO PARA�SO que visitar� o local de est�gio quando necess�rio;' + CHAR(10) +
	'6.6. Realizar a avalia��o do estagi�rio atrav�s de formul�rios espec�ficos propostos pelo CENTRO UNIVERSIT�RIO PARA�SO;' + CHAR(10) +
	'6.7. Assinar os formul�rios de acompanhamento e avalia��o do estagi�rio para fins de comprova��o.' + CHAR(10) 
	AS CLAUSULA6,

	'CL�USULA S�TIMA � DAS COMPET�NCIAS DA CENTRO UNIVERSIT�RIO'
	AS TITULO7,
	'7.1. Preparar, em n�vel preliminar, os (as) universit�rios (as) para o Est�gio.' + CHAR(10) +
	'7.2. Designar, como orientador (a) o Prof (a). ' + #CONSULTA1.ORIENTADOR + ' a quem caber� acompanhamento, orienta��o e avalia��o do (a) ESTAGI�RIO (A), bem como poder� visitar a CONCEDENTE.' + CHAR(10) +
	'7.3. Manter atualizadas as informa��es cadastrais relativas ao Est�gio.' + CHAR(10) +
	'7.4. Providenciar o seguro obrigat�rio contra acidentes pessoais em favor do estagi�rio.' + CHAR(10)
	AS CLAUSULA7,

	'CL�USULA OITAVA � DA RESCIS�O'
	AS TITULO8,
	'8.1.	N�o cumprimento do convencionado nas cl�usulas do Termo de Compromisso de Est�gio.' + CHAR(10) +
	'8.2.	Automaticamente, no t�rmino do prazo previsto no Termo de Compromisso de Est�gio.' + CHAR(10) +
	'8.3.	Trancamento da matr�cula, conclus�o, abandono do curso (desist�ncia) e infrequ�ncia.' + CHAR(10) +
	'8.4.	Contrata��o em regime de CLT.' + CHAR(10) +
	'8.5.	Interesse e conveni�ncia do (a) CONCEDENTE.' + CHAR(10) +
	'8.6.	Interesses particulares do estagi�rio.' + CHAR(10) +
	'8.7.	Serem atribu�das ao (a) estagi�rio (a) atividades reconhecidamente incompat�veis com sua habilita��o ou forma��o.' + CHAR(10) +
	'8.8.	N�o comparecimento ao local do est�gio, sem motivo justificado, por 5 (cinco) dias consecutivos ou 12 (doze) dias alternados, no per�odo de um m�s.' + CHAR(10) +
	'8.9.	N�o cumprimento da cl�usula 4� deste presente Termo de Compromisso de Est�gio.' + CHAR(10)
	AS CLAUSULA8,

	'CL�USULA NONA � DAS DISPOSI��ES GERAIS'
	AS TITULO9,
	'9.1. O (a) ESTAGI�RIO(A), cumpridas as cl�usulas acima, para quaisquer efeitos, n�o ter� v�nculo empregat�cio com a CONCEDENTE, conforme o artigo 3� da Lei n� 11.788, de 25/09/2008.' + CHAR(10) +
	'Par�grafo �nico: E por estarem concordes, as partes signat�rias deste instrumento elegem o foro da cidade de Juazeiro do Norte (CE) para dirimir eventuais pend�ncias e subscrevem-no em tr�s vias de igual teor, ficando uma c�pia sob a guarda do ESTAGI�RIO (A), outra com a CONCEDENTE e outra com o CENTRO UNIVERSIT�RIO PARA�SO.'
	AS CLAUSULA9
FROM #CONSULTA1


ELSE IF ((@IDTURMADISC IS NOT NULL) AND (@ESTAGIOOBRIGATORIO = 'S') AND (@CATEGORIA <> 5))
SELECT
	'TERMO DE COMPROMISSO DE EST�GIO OBRIGAT�RIO'
	AS TITULO,

	'Que entre si celebram, de um lado ' + #CONSULTA1.NOME_EMPRESA + ', situada � ' + #CONSULTA1.RUA_EMPRESA + ', ' + #CONSULTA1.NUMERO_EMPRESA + ', ' + #CONSULTA1.BAIRRO_EMPRESA + ', ' + #CONSULTA1.MUNICIPIO_EMPRESA + ', ' + #CONSULTA1.ESTADO_EMPRESA + ', nesta cidade, com CNPJ: ' + #CONSULTA1.CNPJ + ' doravante denominada simplesmente EMPRESA, neste ato representada pelo Sr(a) ' + #CONSULTA1.RESPONSAVEL + ', e de outro o(a) aluno(a) ' + #CONSULTA1.ALUNO + ', regularmente matriculado(a) no Curso de ' + #CONSULTA1.CURSO_ALUNO + ' do Centro Universit�rio Para�so, doravante denominado(a) simplesmente ESTAGI�RIO(A), residente ' + #CONSULTA1.RUA_ALUNO + ', ' + #CONSULTA1.NUMERO_ALUNO + ', ' + #CONSULTA1.BAIRRO_ALUNO + ', ' + #CONSULTA1.MUNICIPIO_ALUNO + ', ' + #CONSULTA1.ESTADO_ALUNO + ', telefone ' + #CONSULTA1.TELEFONE_ALUNO + ', e contando com a interveni�ncia do CENTRO UNIVERSIT�RIO PARA�SO, institui��o de ensino superior, com sede � Rua S�o Benedito, 344 � S�o Miguel � Juazeiro do Norte, Estado do Cear�, doravante denominado CENTRO UNIVERSIT�RIO PARA�SO, neste ato representada por Jo�o Luis Alexandre Fi�sa, Reitor.'
	AS INTRO,

	'CL�USULA 1� � DOS OBJETIVOS DO EST�GIO CURRICULAR SUPERVISIONADO'
	AS TITULO1,
	'I - proporcionar ao ESTAGI�RIO atividades que visem ao aprendizado na sua �rea de forma��o acad�mica possibilitando aliar a teoria � pr�tica profissional;' + CHAR(10) + 'II - possibilitar � CENTRO UNIVERSIT�RIO PARA�SO mais de um caminho para a obten��o de subs�dios necess�rios � atualiza��o de seus curr�culos, bem como � EMPRESA mais um canal de informa��es indispens�veis � constante aproxima��o das fontes de conhecimentos t�cnicos e cient�ficos.'
	AS CLAUSULA1,

	'CL�USULA 2� � DAS COMPET�NCIAS DA EMPRESA'
	AS TITULO2,
	'I- oportunizar as tarefas que ser�o desenvolvidas pelo ESTAGI�RIO (A), de acordo com os objetivos da disciplina de est�gio que o aluno est� cursando;' + CHAR(10) +
	'II- designar Supervisor de est�gio na empresa, a quem competir� articular-se com o(a) Professor(a) orientador(a) de est�gio especificado pelo CENTRO UNIVERSIT�RIO PARA�SO, respeitando o limite de at� 10(dez) estagi�rios simultaneamente;' + CHAR(10) +
	'III - o supervisor da EMPRESA sempre que poss�vel, dever� ter conhecimento ou viv�ncia na �rea de atua��o do ESTAGI�RIO (A);' + CHAR(10) +
	'IV - possibilitar o acesso do(a) Professor(a) orientador(a) designado(a) pelo CENTRO UNIVERSIT�RIO PARA�SO que visitar� o local de est�gio quando necess�rio;' + CHAR(10) +
	'V � realizar a avalia��o do estagi�rio atrav�s de formul�rios espec�ficos propostos pelo CENTRO UNIVERSIT�RIO PARA�SO;' + CHAR(10) +
	'VI � assinar os formul�rios de acompanhamento e avalia��o do estagi�rio para fins de comprova��o.'
	AS CLAUSULA2,

	'CL�USULA 3� � DAS COMPET�NCIAS DO CENTRO UNIVERSIT�RIO'
	AS TITULO3,
	'I - preparar, em n�vel preliminar, os (as) universit�rios (as) para o Est�gio;' + CHAR(10) + 
	'II - designar, como orientador (a) o Prof (a).' + #CONSULTA1.ORIENTADOR + ' a quem caber� acompanhamento, orienta��o e avalia��o do (a) ESTAGI�RIO (A), bem como poder� visitar a EMPRESA;' + CHAR(10) + 
	'III - manter atualizadas as informa��es cadastrais relativas ao Est�gio;' + CHAR(10) + 
	'IV - providenciar o seguro obrigat�rio contra acidentes pessoais em favor do estagi�rio;'
	AS CLAUSULA3,

	'CL�USULA 4� - DAS COMPET�NCIAS DO(A) ESTAGI�RIO(A)'
	AS TITULO4,
	'I � estagiar, com periodicidade m�xima de, 24 (vinte e quatro) meses, 30 (trinta) horas semanais, sendo 6(seis) horas di�rias;' + CHAR(10) + 
	'II - realizar as tarefas previstas no seu Plano de Est�gio e, na impossibilidade eventual do cumprimento de algum item dessa programa��o, comunicar por escrito ao Supervisor(a) da EMPRESA e Professor(a) orientador(a), para fins de aprova��o ou n�o;' + CHAR(10) + 
	'III - cumprir as normas da EMPRESA, principalmente as relativas ao Est�gio, que o ESTAGI�RIO(A) declara expressamente conhecer;' + CHAR(10) + 
	'IV - responder por perdas e danos consequentes da inobserv�ncia das normas internas ou das constantes neste Termo de Compromisso seja por dolo ou culpa;' + CHAR(10) + 
	'V - seguir a orienta��o do Supervisor(a) da EMPRESA e do(a) professor(a)  Orientador(a) designado pelo CENTRO UNIVERSIT�RIO PARA�SO;' + CHAR(10) + 
	'VI- apresentar os relat�rios que lhe forem solicitados pela EMPRESA e pelo CENTRO UNIVERSIT�RIO PARA�SO, observando os prazos estabelecidos;' + CHAR(10) + 
	'VII- cumprir a carga hor�ria total de ' + #CONSULTA1.CHSEMANAL + ' horas, realizando o est�gio no hor�rio de ' + #CONSULTA1.HRINICIO + ' horas a ' + #CONSULTA1.HRFIM + ' horas, tendo como supervisor t�cnico o Sr.(a) ' + #CONSULTA1.SUPERVISOR + ';' + CHAR(10) + 
	'VIII - realizar as seguintes atividades: ' + #CONSULTA1.OBJETIVO + ';' + CHAR(10) + 
	'IX - cumprir o est�gio no per�odo de ' + #CONSULTA1.DTINICIOESTAGIO + ' a ' + #CONSULTA1.DTFINALESTAGIO + '.'
	AS CLAUSULA4,

	'CL�USULA 5� � DAS DISPOSI��ES GERAIS'
	AS TITULO5,
	'I - o (a) ESTAGI�RIO(A) cumprido as cl�usulas acima, para quaisquer efeitos, n�o ter� v�nculo empregat�cio com a EMPRESA, conforme o artigo 3� da Lei n� 11.788, de 25/09/2008.' + CHAR(10) +
	'Par�grafo �nico: E por estarem concordes, as partes signat�rias deste instrumento elegem o foro da cidade de Juazeiro do Norte (CE) para dirimir eventuais pend�ncias e subscrevem-no em tr�s vias de igual teor, ficando uma c�pia sob a guarda do ESTAGI�RIO (A), outra com a EMPRESA e outra com a CENTRO UNIVERSIT�RIO PARA�SO.'
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

