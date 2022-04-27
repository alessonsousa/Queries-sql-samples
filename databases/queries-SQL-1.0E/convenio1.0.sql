DECLARE @IDTURMADISC INT = (
    SELECT
        IDTURMADISC
    FROM 
        SESTAGIOCONTRATO
    WHERE
            IDPERLET = 167
        AND IDHABILITACAOFILIAL = 117		
        AND CODCOLIGADA = 1				
        AND RA = '2019110084'			
	)


DECLARE @ESTAGIOOBRIGATORIO VARCHAR(5) = (
    SELECT
        ESTAGIOOBRIGATORIO
    FROM 
        SESTAGIOCONTRATO
    WHERE
            IDPERLET = 167
        AND IDHABILITACAOFILIAL = 117		
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
            SESTAGIOCONTRATO.IDPERLET = 167
        AND SESTAGIOCONTRATO.IDHABILITACAOFILIAL = 117		
        AND SESTAGIOCONTRATO.CODCOLIGADA = 1				
        AND SESTAGIOCONTRATO.RA = '2019110084'				
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
				SESTAGIOCONTRATO.IDPERLET = 167
			AND SESTAGIOCONTRATO.IDHABILITACAOFILIAL = 117		
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
				SESTAGIOCONTRATO.IDPERLET = 167
			AND SESTAGIOCONTRATO.IDHABILITACAOFILIAL = 117		
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
				SESTAGIOCONTRATO.IDPERLET = 167
			AND SESTAGIOCONTRATO.IDHABILITACAOFILIAL = 117		
			AND SESTAGIOCONTRATO.CODCOLIGADA = 1				
			AND SESTAGIOCONTRATO.RA = '2019110084'			
			) AS DADOS_ALUNO ON
					DADOS_ALUNO.IDESTAGIOCONTRATO_ALUNO = DADOS_ESTAGIO.IDESTAGIOCONTRATO_ESTAGIO
	) AS CONSULTA


/* Est�gio OBRIGAT�RIO com EMPRESA */
IF ((@IDTURMADISC IS NOT NULL) AND (@ESTAGIOOBRIGATORIO = 'S') AND (@CATEGORIA <> 5))
    SELECT
		'Est�gio OBRIGAT�RIO com EMPRESA'
		AS TIPO,

        'CONV�NIO'
        AS TITULO,

        'Conv�nio que celebram entre si o Educacional Fi�sa S/S Ltda, inscrito no Minist�rio da Fazenda sob o CNPJ n� 04.242.942/0001-37, na qualidade de mantenedor do CENTRO UNIVERSAT�RIO PARA�SO, institui��o de ensino superior, com sede Rua S�o Benedito, 344 � S�o Miguel � Juazeiro do Norte, CEP 63010-220, Estado do Cear� doravante denominada CENTRO UNIVERSIT�RIO PARA�SO e ' + #CONSULTA1.NOME_EMPRESA + ' localizada' + #CONSULTA1.RUA_EMPRESA + ', ' + #CONSULTA1.NUMERO_EMPRESA + ', ' + #CONSULTA1.BAIRRO_EMPRESA + ', ' + #CONSULTA1.MUNICIPIO_EMPRESA + ', ' + #CONSULTA1.ESTADO_EMPRESA + ', com o fim de colaborarem reciprocamente no planejamento, execu��o e avalia��o dos Est�gios Obrigat�rios, conforme o que determina a Lei n� 11.788, de 25/09/2008 e Projeto Pedag�gico dos Cursos da Faculdade Para�so.'
        AS PREINTRO,

        'O CENTRO UNIVERSIT�RIO PARA�SO, doravante denominado CENTRO UNIVERSIT�RIO, neste ato representada por seu Reitor Jo�o Luis Alexandre Fi�sa e ' + #CONSULTA1.NOME_EMPRESA + ' doravante denominada EMPRESA, neste ato representada por Sr.(a) ' + #CONSULTA1.RESPONSAVEL + ' t�m justo e acertado o consubstanciado nas seguintes cl�usulas:'
        AS INTRO,

        'CL�USULA 1� - DO OBJETIVO DO CONV�NIO'
        AS TITULO1,
        'O presente Conv�nio objetiva estabelecer as condi��es para a realiza��o dos Est�gios Curriculares Obrigat�rios, observando o preceituado na Lei n� 11.788, de 25/09/2008 e nos Projetos Pedag�gicos da Faculdade Para�so.'
        AS CLAUSULA1,

        'CL�USULA 2� - DA NATUREZA DO EST�GIO OBRIGAT�RIO '
        AS TITULO2,
        'Considera-se Est�gio Obrigat�rio aquele definido no projeto pedag�gico do curso, cuja carga hor�ria � requisito necess�rio para a aprova��o e obten��o do diploma. � um ato educativo escolar supervisionado, desenvolvido no ambiente de trabalho. '
        AS CLAUSULA2,

        'CL�USULA 3� - DA FINALIDADE DO EST�GIO OBRIGAT�RIO'
        AS TITULO3,
        'O est�gio obrigat�rio tem como finalidade ensejar a aplica��o dos conhecimentos adquiridos, permitindo o desenvolvimento das habilidades t�cnico-cient�ficas para melhor qualifica��o, bem como o desenvolvimento de compet�ncias do futuro profissional e oferecer subs�dios � revis�o curricular, � adequa��o de programas e metodologias. Para a empresa poder� gerar melhorias no seu processo produtivo ou vantagem competitiva a partir da possibilidade de sugest�es apresentadas.'
        AS CLAUSULA3,

        'CL�USULA 4� - DAS COMPET�NCIAS DO CENTRO UNIVERSIT�RIO PARA�SO'
        AS TITULO4,
        'I - celebrar Termo de Compromisso de Est�gio com o educando e com a parte concedente, indicando as condi��es de adequa��o do est�gio em rela��o � proposta pedag�gica do curso, etapa da forma��o acad�mica, hor�rio e calend�rio acad�mico;' + CHAR(10) +
        'II - avaliar as instala��es da parte concedente de est�gio;' + CHAR(10) +
        'III - indicar professor orientador da �rea a ser desenvolvida no est�gio, como respons�vel pelo acompanhamento e avalia��o das atividades do estagi�rio;' + CHAR(10) +
        'IV - exigir do educando a apresenta��o peri�dica de relat�rios e formul�rios para fins de acompanhamento e avalia��o;' + CHAR(10) +
        'V - zelar pelo cumprimento do Termo de Compromisso de Est�gio, em conson�ncia com a empresa concedente;' + CHAR(10) +
        'VI - elaborar normas complementares e instrumentos de avalia��o dos est�gios de seus educandos;' + CHAR(10) +
        'VII � comunicar � parte concedente do est�gio as datas de avalia��es acad�micas ou entrega de relat�rios e formul�rios;' + CHAR(10) +
        'VIII - responsabilizar-se pelo seguro obrigat�rio em favor do aluno estagi�rio.'
        AS CLAUSULA4,

        'CL�USULA 5� - DAS COMPET�NCIAS DA EMPRESA'
        AS TITULO5,
        'I - definir sua pol�tica de est�gio, planejando adequadamente o est�gio de estudantes em seus quadros;' + CHAR(10) +
        'II - oferecer oportunidades de est�gio na �rea de forma��o acad�mica do estagi�rio;' + CHAR(10) +
        'III - receber os estudantes selecionados e encaminhados pelo CENTRO UNIVERSIT�RIO PARA�SO;' + CHAR(10) +
        'IV - articular-se com o CENTRO UNIVERSIT�RIO PARA�SO com o objetivo de compatibilizar a orienta��o oriunda do ponto de vista da produ��o com a orienta��o decorrente da �tica do ensino;' + CHAR(10) +
        'V - permitir o acesso de representantes credenciados do CENTRO UNIVERSIT�RIO PARA�SO ao local de est�gio, segundo periodicidade a ser estabelecida com o CENTRO UNIVERSIT�RIO PARA�SO, objetivando o acompanhamento e a avalia��o do est�gio;' + CHAR(10) +
        'VI - firmar o Termo de Compromisso com o estagi�rio, com a interveni�ncia da CENTRO UNIVERSIT�RIO PARA�SO;' + CHAR(10) +
        'VII - oferecer instala��es que propiciem ao educando atividades de aprendizagem social, profissional e cultural;' + CHAR(10) +
        'VIII - indicar funcion�rio do seu quadro de pessoal, com forma��o ou experi�ncia profissional na �rea de conhecimento do estagi�rio, para supervisionar at� 10 (dez) estagi�rios simultaneamente;' + CHAR(10) +
        'IX � zelar para que a carga hor�ria m�xima do estagi�rio corresponda a, no m�ximo, 6 horas di�rias e 30 horas semanais;' + CHAR(10) +
        'X � permitir a redu��o da carga hor�ria do estagi�rio pelo menos � metade da jornada di�ria estipulada no Termo de Compromisso de Est�gio nos per�odos de avalia��es calendarizadas pela CENTRO UNIVERSIT�RIO PARA�SO.' + CHAR(10) +
        'Par�grafo �nico: O est�gio nessa forma prevista n�o gera vinculo empregat�cio para as partes.'
        AS CLAUSULA5,

        'CL�USULA 6� � DAS COMPET�NCIAS DO ESTAGI�RIO'
        AS TITULO6,
        'I - cumprir o que for proposto no plano de est�gio, em conformidade com o professor orientador e supervisor de est�gio;' + CHAR(10) +
        'II - zelar pelos equipamentos, materiais e documentos da empresa;' + CHAR(10) +
        'III - manter sigilo sobre informa��es escritas ou verbais da empresa, adotando postura �tica profissional.'
        AS CLAUSULA6,

        'CL�USULA 7� � DO DESLIGAMENTO OU SUBSTITUI��O DE EST�GIO'
        AS TITULO7,
        'A empresa poder� solicitar, a qualquer momento, o desligamento e/ou a substitui��o de estagi�rios nos casos previstos pela legisla��o vigente, dando ci�ncia � CENTRO UNIVERSIT�RIO PARA�SO, bem como a pr�pria I.E.S ou o pr�prio estagi�rio requerer o desligamento.'
        AS CLAUSULA7,

        'CL�USULA 8� � DA VIG�NCIA'
        AS TITULO8,
        'O presente conv�nio ter� vig�ncia de 02 anos (dois anos), a partir da data de sua assinatura, podendo ser prorrogado automaticamente, a cada ano, se nenhuma das partes se pronunciarem em contr�rio, at� 30 (trinta) dias antes do t�rmino.'
        AS CLAUSULA8,

        'CL�USULA 9� � DA RESCIS�O'
        AS TITULO9,
        'Este conv�nio poder� ser denunciado por qualquer das partes a qualquer tempo, mediante correspond�ncia que anteceder� 30 (trinta) dias, no m�nimo, � vig�ncia da cessa��o do presente pacto, indicando as raz�es da den�ncia.' + CHAR(10) +
        'E por estarem concordes, as partes signat�rias deste instrumento elegem o foro da cidade de Juazeiro do Norte (CE) para dirimir eventuais pend�ncias e subscrevem � se em duas vias de igual teor e forma.'
        AS CLAUSULA9
FROM #CONSULTA1

/* Est�gio OBRIGAT�RIO com PROFISSIONAL LIBERAL */
ELSE IF ((@IDTURMADISC IS NOT NULL) AND (@ESTAGIOOBRIGATORIO = 'S') AND (@CATEGORIA = 5))
    SELECT
		'Est�gio OBRIGAT�RIO com PROFISSIONAL LIBERAL'
		AS TIPO,

        'CONV�NIO'
        AS TITULO,

        'Termo de conv�nio que entre si celebram, de um lado, o CENTRO UNIVERSIT�RIO PARA�SO, e de outro lado, ' + #CONSULTA1.NOME_EMPRESA + ', visando � realiza��o de est�gio.'
        AS PREINTRO,

        'O CENTRO UNIVERSIT�RIO PARA�SO, doravante denominada CENTRO UNIVERSIT�RIO PARA�SO, Institui��o de Ensino Superior Privada, mantida por Fi�sa Educacional S/Simples Ltda., regularmente inscrita no CNPJ/MF sob o n� 04.242.942/0001-37, com sede � Rua S�o Benedito, 344, CEP 63010-220, Bairro S�o Miguel, em Juazeiro do Norte (CE), neste ato representada pelo seu Reitor, Professor Jo�o Luis Alexandre Fi�sa, e ' + #CONSULTA1.NOME_EMPRESA + ', doravante denominada(o) CONCEDENTE, pessoa f�sica com n� de Registro  Profissional sob o n�mero ' + #CONSULTA1.CNPJ + ', portador(a) da c�dula de identidade n� ' + #CONSULTA1.CARTIDENTIDADE + ', SSP/' + #CONSULTA1.UFCARTIDENT + ', inscrita(o) no CPF sob o n� ' + #CONSULTA1.CPF_SUPERVISOR + ', residente � Rua ' + #CONSULTA1.RUA_EMPRESA + ', n� ' + #CONSULTA1.NUMERO_EMPRESA + ', Bairro ' + #CONSULTA1.BAIRRO_EMPRESA + ', CEP ' + #CONSULTA1.CEP_EMPRESA + ', na cidade de ' + #CONSULTA1.MUNICIPIO_EMPRESA + ' � ' + #CONSULTA1.ESTADO_EMPRESA + ', resolvem celebrar o presente conv�nio, que ser� regido pela Lei n� 11.788, de 25/09/08, mediante as seguintes cl�usulas e condi��es:'
        AS INTRO,

        'CL�USULA 1� - DO OBJETO, DA CLASSIFICA��O E DAS RELA��ES DE EST�GIO'
        AS TITULO1,
        '1.1.   O presente conv�nio tem por objetivo regular as rela��es entre as partes ora conveniadas no que tange � concess�o de est�gio curricular supervisionado para estudantes regularmente matriculados e que venham frequentando efetivamente cursos oferecidos pelo CENTRO UNIVERSIT�RIO PARA�SO, nos termos da Lei n� 11.788, de 25 de setembro de 2008.' + CHAR(10) +
        '1.2.   Para os fins deste conv�nio, entende-se como est�gio as atividades proporcionadas ao aluno de gradua��o, em situa��es reais da profiss�o e do trabalho, ligadas � sua �rea de forma��o no CENTRO UNIVERSIT�RIO PARA�SO e previstas no Projeto Pedag�gico do Curso.' + CHAR(10) +
        '1.3.   O est�gio obrigat�rio n�o cria v�nculo empregat�cio de qualquer natureza.'
        AS CLAUSULA1,

        'CL�USULA 2� - DAS COMPET�NCIAS DO CENTRO UNIVERSIT�RIO PARA�SO'
        AS TITULO2,
        '2.1.   Celebrar, atrav�s da Coordenadoria de Est�gios/Coordenadoria de Gradua��o dos Cursos, Termo de Compromisso de Est�gio com a parte CONCEDENTE e o aluno.' + CHAR(10) +
        '2.2.   Avaliar as instala��es da parte CONCEDENTE e a sua adequa��o � forma��o cultural e profissional do aluno.' + CHAR(10) +
        '2.3.   Indicar um professor orientador da �rea a ser desenvolvida no est�gio como respons�vel pelo acompanhamento e avalia��o das atividades do estagi�rio.' + CHAR(10) +
        '2.4.   Exigir do estagi�rio, em prazo n�o superior a um semestre acad�mico, relat�rio de atividades conforme estabelecido no termo de compromisso e nas normas do curso. O relat�rio deve ser entregue pelo aluno ao Coordenador de Est�gios do curso devidamente assinado pelas partes envolvidas;' + CHAR(10) +
        '2.5.	Elaborar normas complementares e instrumentos de avalia��o dos est�gios dos seus educandos;' + CHAR(10) +
        '2.6.	Informar, atrav�s de declara��o subscrita pelo professor da disciplina, mediante solicita��o do aluno, as datas de avalia��es escolares ou acad�micas para fins de redu��o da carga hor�ria de est�gio no per�odo;' + CHAR(10) +
        '2.7.	Zelar pelo cumprimento do Termo de Compromisso de Est�gio, reorientando o estagi�rio para outro local em caso de descumprimento de suas cl�usulas por parte da CONCEDENTE.' + CHAR(10) +
        '2.8.	Comunicar � CONCEDENTE os casos de conclus�o ou abandono de curso, cancelamento ou trancamento da matr�cula.' + CHAR(10) +
        '2.9.	Efetuar, mensalmente, o pagamento do seguro contra acidentes pessoais para o aluno em est�gio obrigat�rio.'
        AS CLAUSULA2,

        'CL�USULA 3� � DAS OBRIGA��ES DA CONCEDENTE'
        AS TITULO3,
        'Compete � CONCEDENTE:' + CHAR(10) +
        '3.1.   Conceder est�gios ao corpo discente do CENTRO UNIVERSIT�RIO PARA�SO, observadas a legisla��o vigente e as disposi��es deste conv�nio.' + CHAR(10) +
        '3.2.	Comunicar ao CENTRO UNIVERSIT�RIO PARA�SO o n�mero de vagas de est�gio dispon�veis por curso/�rea de forma��o, para a devida divulga��o e encaminhamento de alunos.' + CHAR(10) +
        '3.3.	Selecionar os estagi�rios dentre os alunos encaminhados pelo CENTRO UNIVERSIT�RIO PARA�SO.' + CHAR(10) +
        '3.4.	Celebrar Termo de Compromisso de Est�gio com o CENTRO UNIVERSIT�RIO PARA�SO e com o aluno, zelando pelo seu cumprimento.' + CHAR(10) +
        '3.5.	Ofertar instala��es que tenham condi��es de proporcionar ao educando atividades de aprendizagem social, profissional e cultural, observando o estabelecido na legisla��o relacionada � sa�de e seguran�a no trabalho.' + CHAR(10) +
        '3.6.	Indicar um funcion�rio de seu quadro de pessoal, com forma��o ou experi�ncia profissional na �rea de conhecimento desenvolvida no curso do estagi�rio, para orientar e supervisionar as atividades desenvolvidas pelo estagi�rio. ' + CHAR(10) +
        '3.7.	Zelar para que a carga hor�ria m�xima do estagi�rio corresponda a, no m�ximo, 6 horas di�rias e 30 horas semanais.' + CHAR(10) +
        '3.8.	Assegurar ao estagi�rio, sempre que o est�gio tenha a dura��o igual ou superior a 1 (um) ano, o per�odo de recesso de 30 (trinta) dias, a ser gozado preferencialmente no per�odo de f�rias escolares.' + CHAR(10) +
        '3.9.	Encaminhar, por ocasi�o do desligamento do estagi�rio, o termo de realiza��o de est�gio ao Coordenador de Est�gio/de gradua��o do curso, com a indica��o resumida das atividades desenvolvidas, dos per�odos e da avalia��o de desempenho.  ' + CHAR(10) +
        '3.10.	Informar ao CENTRO UNIVERSIT�RIO PARA�SO sobre a frequ�ncia e o desempenho dos estagi�rios, observadas as exig�ncias de cada curso, quando for o caso.' + CHAR(10) +
        '3.11.	Indicar CENTRO UNIVERSIT�RIO PARA�SO, para ser substitu�do, o estagi�rio que, por motivo de natureza t�cnica, administrativa ou disciplinar, n�o for considerado apto a continuar suas atividades de est�gio.'
        AS CLAUSULA3,

        'CL�USULA 4� � DAS COMPET�NCIAS DO ESTAGI�RIO'
        AS TITULO4,
        '4.1.   Cumprir o que for proposto no plano de est�gio, em conformidade com o professor orientador e supervisor de est�gio.' + CHAR(10) +
        '4.2.   Zelar pelos equipamentos, materiais e documentos da empresa.' + CHAR(10) +
        '4.3.   Manter sigilo sobre informa��es escritas ou verbais da empresa, adotando postura �tica profissional.'
        AS CLAUSULA4,

        'CL�USULA 5� � DO DESLIGAMENTO OU SUBSTITUI��O DE EST�GIO'
        AS TITULO5,
        'A concedente poder� solicitar, a qualquer momento, o desligamento e/ou a substitui��o de estagi�rios nos casos previstos pela legisla��o vigente, dando ci�ncia � CENTRO UNIVERSIT�RIO PARA�SO, bem como a pr�pria I.E.S ou o pr�prio estagi�rio requerer o desligamento.'
        AS CLAUSULA5,

        'CL�USULA 6� � DO DESLIGAMENTO OU SUBSTITUI��O DO ESTAGI�RIO'
        AS TITULO6,
        'Qualquer uma das partes pode solicitar o desligamento do estagi�rio, dando ci�ncia ao CENTRO UNIVERSIT�RIO PARA�SO quando for por iniciativa da empresa ou do pr�prio estagi�rio, no prazo m�nimo de 30(trinta) dias.'
        AS CLAUSULA6,

        'CL�USULA 7� � DA VIG�NCIA'
        AS TITULO7,
        'O presente conv�nio ter� vig�ncia de 24 (vinte e quatro) meses, a partir da data de sua assinatura, podendo ser prorrogado automaticamente, a cada ano, se nenhuma das partes se pronunciarem em contr�rio, at� 30 (trinta) dias antes do t�rmino.'
        AS CLAUSULA7,
        
        'CL�USULA 8� � DA RESCIS�O'
        AS TITULO8,
        'Este conv�nio poder� ser denunciado pelas partes a qualquer tempo, mediante correspond�ncia que anteceder� 30 (trinta) dias, no m�nimo, � vig�ncia da cessa��o do presente pacto, indicando as raz�es da den�ncia.' + CHAR(10) +
        'E por estarem concordes, as partes signat�rias deste instrumento elegem o munic�pio de Juazeiro do Norte - CE para dirimir eventuais pend�ncias e subscrevem-se em duas vias de igual teor e forma.'
        AS CLAUSULA8,

        NULL
        AS TITULO9,
        NULL
        AS CLAUSULA9
FROM #CONSULTA1

/* Est�gio N�O-OBRIGAT�RIO */
ELSE IF ((@IDTURMADISC IS NULL) AND (@ESTAGIOOBRIGATORIO = 'N' OR @ESTAGIOOBRIGATORIO IS NULL))
SELECT
	'Est�gio N�O-OBRIGAT�RIO'
	AS TIPO,

	'CONV�NIO'
	AS TITULO,

    'Conv�nio que celebram entre si o Educacional Fi�sa S/S Ltda, CNPJ n� 04.242.942/0001-37, na qualidade de mantenedor do CENTRO UNIVERSIT�RIO PARA�SO, institui��o de ensino superior, com sede � Rua S�o Benedito, 344 � S�o Miguel � Juazeiro do Norte, CEP 63010-220, Estado do Cear�, doravante denominado CENTRO UNIVERSIT�RIO PARA�SO e ' + #CONSULTA1.NOME_EMPRESA + ' CNPJ n� ' + #CONSULTA1.CNPJ + ', localizada ' + #CONSULTA1.RUA_EMPRESA + ', ' + #CONSULTA1.NUMERO_EMPRESA + ', ' + #CONSULTA1.BAIRRO_EMPRESA + ', ' + #CONSULTA1.MUNICIPIO_EMPRESA + ', ' + #CONSULTA1.ESTADO_EMPRESA + ', doravante denominada EMPRESA com o fim de colaborarem, reciprocamente, no planejamento, execu��o e avalia��o dos Est�gios N�o-Obrigat�rios, conforme o que determina a Lei n� 11.788, de 25/09/2008.'
    AS PREINTRO,

	'O CENTRO UNIVERSIT�RIO PARA�SO, doravante denominada CENTRO UNIVERSIT�RIO, neste ato representada por seu Reitor, Jo�o Luis Alexandre Fi�sa e ' + #CONSULTA1.NOME_EMPRESA + ' doravante denominada EMPRESA, neste ato representada por Sr.(a) ' + #CONSULTA1.RESPONSAVEL + ' t�m justo e acertado o consubstanciado nas seguintes cl�usulas:'
	AS INTRO,

	'CL�USULA 1� � DOS OBJETIVOS DO EST�GIO CURRICULAR SUPERVISIONADO'
	AS TITULO1,
	'O presente conv�nio objetiva estabelecer as condi��es para a realiza��o dos est�gios n�o-obrigat�rios, observando o preceituado na Lei n� 11.788, de 25/09/2008.'
	AS CLAUSULA1,

	'CL�USULA 2� � DAS COMPET�NCIAS DA EMPRESA'
	AS TITULO2,
	'Considera-se est�gio o ato educativo acad�mico supervisionado, desenvolvido no ambiente de trabalho e relacionado � �rea de forma��o do educando. Caracteriza-se como n�o-obrigat�rio por ser opcional, de iniciativa do estudante e pode ser contabilizado como atividades complementares no Centro Universit�rio Para�so.'
	AS CLAUSULA2,

	'CL�USULA 3� � DAS COMPET�NCIAS DO CENTRO UNIVERSIT�RIO'
	AS TITULO3,
	'O est�gio n�o-obrigat�rio tem como finalidade a aprendizagem de compet�ncias pr�prias da atividade profissional e o desenvolvimento do educando para a vida cidad� e para o trabalho.'
	AS CLAUSULA3,

	'CL�USULA 4� - DAS COMPET�NCIAS DO(A) ESTAGI�RIO(A)'
	AS TITULO4,
	'I - promover o cadastramento e encaminhar candidatos a est�gio, segundo crit�rios de perfil propostos pela empresa;' + CHAR(10) +
    'II - preparar em n�vel preliminar, os universit�rios para o est�gio, sensibilizando-os sobre a oportunidade de adquirirem os conhecimentos pr�ticos, dentro do contexto da atividade produtiva e orientando-os para sua inser��o na hierarquia empresarial e para a pr�tica da disciplina na empresa; ' + CHAR(10) +
    'III -  encaminhar � EMPRESA os estudantes do curso solicitado a partir dos crit�rios de semestre;' + CHAR(10) +
    'IV � indicar professor orientador da �rea a ser desenvolvida no est�gio, como respons�vel pelo acompanhamento e avalia��o das atividades de est�gio;' + CHAR(10) +
    'V- articular-se com a Empresa com o objetivo de compatibilizar a orienta��o decorrente da �tica do ensino, com a orienta��o sob o ponto de vista da produ��o, mediante entrosamento entre o professor orientador, designado pelo CENTRO UNIVERSIT�RIO PARA�SO, e o supervisor do est�gio designado pela EMPRESA, para assistir ao estagi�rio;' + CHAR(10) +
    'VI - proceder com a organiza��o e a avalia��o peri�dica do est�gio, atrav�s de relat�rios de atividades, com periodicidade semestral;' + CHAR(10) +
    'VII � celebrar o Termo de Compromisso com o educando e a empresa;' + CHAR(10) +
    'VIII � preparar ou subsidiar a empresa na elabora��o do plano de atividades de est�gio;' + CHAR(10) +
    'IX - avaliar as instala��es da parte concedente do est�gio e sua adequa��o � forma��o do educando;' + CHAR(10) +
    'X � comunicar � empresa, no in�cio do per�odo letivo, a data de realiza��o das avalia��es peri�dicas, conforme Calend�rio Acad�mico.'
	AS CLAUSULA4,

	'CL�USULA 5� � DAS DISPOSI��ES GERAIS'
	AS TITULO5,
	'I - definir sua pol�tica de est�gio planejando adequadamente o est�gio de estudantes em seus quadros;' + CHAR(10) +
    'II - oferecer oportunidades de est�gio na �rea de forma��o do estagi�rio;' + CHAR(10) +
    'III - receber os estudantes triados e encaminhados pelo CENTRO UNIVERSIT�RIO PARA�SO;' + CHAR(10) +
    'IV - supervisionar as atividades realizadas pelos estagi�rios, indicando funcion�rio do seu quadro de pessoal, com forma��o ou experi�ncia profissional na �rea de conhecimento do estagi�rio, para supervisionar at� 10(dez) estagi�rios simultaneamente;' + CHAR(10) +
    'V - permitir o acesso de representantes credenciados do CENTRO UNIVERSIT�RIO PARA�SO ao local de est�gio, segundo periodicidade a ser estabelecida pelo CENTRO UNIVERSIT�RIO objetivando o acompanhamento e a avalia��o do est�gio;' + CHAR(10) +
    'VI - firmar o Termo de Compromisso com o estagi�rio, com a interveni�ncia do CENTRO UNIVERSIT�RIO PARA�SO;' + CHAR(10) +
    'VII - oferecer instala��es que propiciem ao educando atividades de aprendizagem profissional, social e cultural.' + CHAR(10) +
    'VIII - enviar ao CENTRO UNIVERSIT�RIO PARA�SO relat�rio de atividades com vista obrigat�ria ao estagi�rio, pelo menos a cada seis meses;' + CHAR(10) +
    'IX - contratar em favor do estagi�rio seguro contra acidentes pessoais, com ap�lice compat�vel com valores de mercado e especificar no Termo de Compromisso de Est�gio;' + CHAR(10) +
    'X - observar a dura��o do est�gio que n�o poder� exceder 02(dois) anos, exceto quando se tratar de estagi�rio portador de defici�ncia;' + CHAR(10) +
    'XI - fazer constar  e cumprir a jornada do est�gio no Termo de Compromisso de Est�gio, sendo esta compat�vel com as atividades acad�micas e n�o ultrapassando 06(seis) horas di�rias e 30(trinta) horas semanais;' + CHAR(10) +
    'XII - reduzir a carga hor�ria do est�gio pelo menos � metade, no per�odo de avalia��es calendarizadas pela CENTRO UNIVERSIT�RIO PARA�SO;' + CHAR(10) +
    'XIII - conceder ao estagi�rio pagamento de bolsa-aux�lio ou outra forma de contrapresta��o, al�m do aux�lio transporte;' + CHAR(10) +
    'XIV - assegurar ao estagi�rio, per�odo de recesso remunerado de 30(trinta) dias, a ser gozado, preferencialmente, nos meses de janeiro ou julho, sempre que o est�gio tenha dura��o igual ou superior a 1(um) ano.' + CHAR(10) +
    'Par�grafo �nico: o est�gio n�o-obrigat�rio, atendida as cl�usulas acima, n�o gera v�nculo empregat�cio para as partes.'
    AS CLAUSULA5,

	'CL�USULA 6� � DO DESLIGAMENTO OU SUBSTITUI��O DO ESTAGI�RIO'
    AS TITULO6,
	'Qualquer uma das partes pode solicitar o desligamento do estagi�rio, dando ci�ncia ao CENTRO UNIVERSIT�RIO PARA�SO quando for por iniciativa da empresa ou do pr�prio estagi�rio, no prazo m�nimo de 30(trinta) dias.'
    AS CLAUSULA6,

	'CL�USULA 7� � DA VIG�NCIA'
    AS TITULO7,
	'O presente conv�nio ter� vig�ncia de 24 (vinte e quatro) meses, a partir da data de sua assinatura, podendo ser prorrogado automaticamente, a cada ano, se nenhuma das partes se pronunciarem em contr�rio, at� 30 (trinta) dias antes do t�rmino.'
    AS CLAUSULA7,
	
    'CL�USULA 8� � DA RESCIS�O'
    AS TITULO8,
	'Este conv�nio poder� ser denunciado pelas partes a qualquer tempo, mediante correspond�ncia que anteceder� 30 (trinta) dias, no m�nimo, � vig�ncia da cessa��o do presente pacto, indicando as raz�es da den�ncia.' + CHAR(10) +
    'E por estarem concordes, as partes signat�rias deste instrumento elegem o munic�pio de Juazeiro do Norte - CE para dirimir eventuais pend�ncias e subscrevem-se em duas vias de igual teor e forma.'
    AS CLAUSULA8,

        NULL
        AS TITULO9,
        NULL
        AS CLAUSULA9
FROM #CONSULTA1

DROP TABLE #CONSULTA1
--SELECT * FROM #CONSULTA1