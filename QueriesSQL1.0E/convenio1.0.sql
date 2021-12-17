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


/* Estágio OBRIGATÓRIO com EMPRESA */
IF ((@IDTURMADISC IS NOT NULL) AND (@ESTAGIOOBRIGATORIO = 'S') AND (@CATEGORIA <> 5))
    SELECT
		'Estágio OBRIGATÓRIO com EMPRESA'
		AS TIPO,

        'CONVÊNIO'
        AS TITULO,

        'Convênio que celebram entre si o Educacional Fiúsa S/S Ltda, inscrito no Ministério da Fazenda sob o CNPJ nº 04.242.942/0001-37, na qualidade de mantenedor do CENTRO UNIVERSATÁRIO PARAÍSO, instituição de ensino superior, com sede Rua São Benedito, 344 – São Miguel – Juazeiro do Norte, CEP 63010-220, Estado do Ceará doravante denominada CENTRO UNIVERSITÁRIO PARAÍSO e ' + #CONSULTA1.NOME_EMPRESA + ' localizada' + #CONSULTA1.RUA_EMPRESA + ', ' + #CONSULTA1.NUMERO_EMPRESA + ', ' + #CONSULTA1.BAIRRO_EMPRESA + ', ' + #CONSULTA1.MUNICIPIO_EMPRESA + ', ' + #CONSULTA1.ESTADO_EMPRESA + ', com o fim de colaborarem reciprocamente no planejamento, execução e avaliação dos Estágios Obrigatórios, conforme o que determina a Lei nº 11.788, de 25/09/2008 e Projeto Pedagógico dos Cursos da Faculdade Paraíso.'
        AS PREINTRO,

        'O CENTRO UNIVERSITÁRIO PARAÍSO, doravante denominado CENTRO UNIVERSITÁRIO, neste ato representada por seu Reitor João Luis Alexandre Fiúsa e ' + #CONSULTA1.NOME_EMPRESA + ' doravante denominada EMPRESA, neste ato representada por Sr.(a) ' + #CONSULTA1.RESPONSAVEL + ' têm justo e acertado o consubstanciado nas seguintes cláusulas:'
        AS INTRO,

        'CLÁUSULA 1ª - DO OBJETIVO DO CONVÊNIO'
        AS TITULO1,
        'O presente Convênio objetiva estabelecer as condições para a realização dos Estágios Curriculares Obrigatórios, observando o preceituado na Lei nº 11.788, de 25/09/2008 e nos Projetos Pedagógicos da Faculdade Paraíso.'
        AS CLAUSULA1,

        'CLÁUSULA 2ª - DA NATUREZA DO ESTÁGIO OBRIGATÓRIO '
        AS TITULO2,
        'Considera-se Estágio Obrigatório aquele definido no projeto pedagógico do curso, cuja carga horária é requisito necessário para a aprovação e obtenção do diploma. É um ato educativo escolar supervisionado, desenvolvido no ambiente de trabalho. '
        AS CLAUSULA2,

        'CLÁUSULA 3º - DA FINALIDADE DO ESTÁGIO OBRIGATÓRIO'
        AS TITULO3,
        'O estágio obrigatório tem como finalidade ensejar a aplicação dos conhecimentos adquiridos, permitindo o desenvolvimento das habilidades técnico-científicas para melhor qualificação, bem como o desenvolvimento de competências do futuro profissional e oferecer subsídios à revisão curricular, à adequação de programas e metodologias. Para a empresa poderá gerar melhorias no seu processo produtivo ou vantagem competitiva a partir da possibilidade de sugestões apresentadas.'
        AS CLAUSULA3,

        'CLÁUSULA 4ª - DAS COMPETÊNCIAS DO CENTRO UNIVERSITÁRIO PARAÍSO'
        AS TITULO4,
        'I - celebrar Termo de Compromisso de Estágio com o educando e com a parte concedente, indicando as condições de adequação do estágio em relação à proposta pedagógica do curso, etapa da formação acadêmica, horário e calendário acadêmico;' + CHAR(10) +
        'II - avaliar as instalações da parte concedente de estágio;' + CHAR(10) +
        'III - indicar professor orientador da área a ser desenvolvida no estágio, como responsável pelo acompanhamento e avaliação das atividades do estagiário;' + CHAR(10) +
        'IV - exigir do educando a apresentação periódica de relatórios e formulários para fins de acompanhamento e avaliação;' + CHAR(10) +
        'V - zelar pelo cumprimento do Termo de Compromisso de Estágio, em consonância com a empresa concedente;' + CHAR(10) +
        'VI - elaborar normas complementares e instrumentos de avaliação dos estágios de seus educandos;' + CHAR(10) +
        'VII – comunicar à parte concedente do estágio as datas de avaliações acadêmicas ou entrega de relatórios e formulários;' + CHAR(10) +
        'VIII - responsabilizar-se pelo seguro obrigatório em favor do aluno estagiário.'
        AS CLAUSULA4,

        'CLÁUSULA 5ª - DAS COMPETÊNCIAS DA EMPRESA'
        AS TITULO5,
        'I - definir sua política de estágio, planejando adequadamente o estágio de estudantes em seus quadros;' + CHAR(10) +
        'II - oferecer oportunidades de estágio na área de formação acadêmica do estagiário;' + CHAR(10) +
        'III - receber os estudantes selecionados e encaminhados pelo CENTRO UNIVERSITÁRIO PARAÍSO;' + CHAR(10) +
        'IV - articular-se com o CENTRO UNIVERSITÁRIO PARAÍSO com o objetivo de compatibilizar a orientação oriunda do ponto de vista da produção com a orientação decorrente da ótica do ensino;' + CHAR(10) +
        'V - permitir o acesso de representantes credenciados do CENTRO UNIVERSITÁRIO PARAÍSO ao local de estágio, segundo periodicidade a ser estabelecida com o CENTRO UNIVERSITÁRIO PARAÍSO, objetivando o acompanhamento e a avaliação do estágio;' + CHAR(10) +
        'VI - firmar o Termo de Compromisso com o estagiário, com a interveniência da CENTRO UNIVERSITÁRIO PARAÍSO;' + CHAR(10) +
        'VII - oferecer instalações que propiciem ao educando atividades de aprendizagem social, profissional e cultural;' + CHAR(10) +
        'VIII - indicar funcionário do seu quadro de pessoal, com formação ou experiência profissional na área de conhecimento do estagiário, para supervisionar até 10 (dez) estagiários simultaneamente;' + CHAR(10) +
        'IX – zelar para que a carga horária máxima do estagiário corresponda a, no máximo, 6 horas diárias e 30 horas semanais;' + CHAR(10) +
        'X – permitir a redução da carga horária do estagiário pelo menos à metade da jornada diária estipulada no Termo de Compromisso de Estágio nos períodos de avaliações calendarizadas pela CENTRO UNIVERSITÁRIO PARAÍSO.' + CHAR(10) +
        'Parágrafo único: O estágio nessa forma prevista não gera vinculo empregatício para as partes.'
        AS CLAUSULA5,

        'CLÁUSULA 6ª – DAS COMPETÊNCIAS DO ESTAGIÁRIO'
        AS TITULO6,
        'I - cumprir o que for proposto no plano de estágio, em conformidade com o professor orientador e supervisor de estágio;' + CHAR(10) +
        'II - zelar pelos equipamentos, materiais e documentos da empresa;' + CHAR(10) +
        'III - manter sigilo sobre informações escritas ou verbais da empresa, adotando postura ética profissional.'
        AS CLAUSULA6,

        'CLÁUSULA 7ª – DO DESLIGAMENTO OU SUBSTITUIÇÃO DE ESTÁGIO'
        AS TITULO7,
        'A empresa poderá solicitar, a qualquer momento, o desligamento e/ou a substituição de estagiários nos casos previstos pela legislação vigente, dando ciência à CENTRO UNIVERSITÁRIO PARAÍSO, bem como a própria I.E.S ou o próprio estagiário requerer o desligamento.'
        AS CLAUSULA7,

        'CLÁUSULA 8ª – DA VIGÊNCIA'
        AS TITULO8,
        'O presente convênio terá vigência de 02 anos (dois anos), a partir da data de sua assinatura, podendo ser prorrogado automaticamente, a cada ano, se nenhuma das partes se pronunciarem em contrário, até 30 (trinta) dias antes do término.'
        AS CLAUSULA8,

        'CLÁUSULA 9ª – DA RESCISÃO'
        AS TITULO9,
        'Este convênio poderá ser denunciado por qualquer das partes a qualquer tempo, mediante correspondência que antecederá 30 (trinta) dias, no mínimo, à vigência da cessação do presente pacto, indicando as razões da denúncia.' + CHAR(10) +
        'E por estarem concordes, as partes signatárias deste instrumento elegem o foro da cidade de Juazeiro do Norte (CE) para dirimir eventuais pendências e subscrevem – se em duas vias de igual teor e forma.'
        AS CLAUSULA9
FROM #CONSULTA1

/* Estágio OBRIGATÓRIO com PROFISSIONAL LIBERAL */
ELSE IF ((@IDTURMADISC IS NOT NULL) AND (@ESTAGIOOBRIGATORIO = 'S') AND (@CATEGORIA = 5))
    SELECT
		'Estágio OBRIGATÓRIO com PROFISSIONAL LIBERAL'
		AS TIPO,

        'CONVÊNIO'
        AS TITULO,

        'Termo de convênio que entre si celebram, de um lado, o CENTRO UNIVERSITÁRIO PARAÍSO, e de outro lado, ' + #CONSULTA1.NOME_EMPRESA + ', visando à realização de estágio.'
        AS PREINTRO,

        'O CENTRO UNIVERSITÁRIO PARAÍSO, doravante denominada CENTRO UNIVERSITÁRIO PARAÍSO, Instituição de Ensino Superior Privada, mantida por Fiúsa Educacional S/Simples Ltda., regularmente inscrita no CNPJ/MF sob o nº 04.242.942/0001-37, com sede à Rua São Benedito, 344, CEP 63010-220, Bairro São Miguel, em Juazeiro do Norte (CE), neste ato representada pelo seu Reitor, Professor João Luis Alexandre Fiúsa, e ' + #CONSULTA1.NOME_EMPRESA + ', doravante denominada(o) CONCEDENTE, pessoa física com nº de Registro  Profissional sob o número ' + #CONSULTA1.CNPJ + ', portador(a) da cédula de identidade nº ' + #CONSULTA1.CARTIDENTIDADE + ', SSP/' + #CONSULTA1.UFCARTIDENT + ', inscrita(o) no CPF sob o nº ' + #CONSULTA1.CPF_SUPERVISOR + ', residente à Rua ' + #CONSULTA1.RUA_EMPRESA + ', nº ' + #CONSULTA1.NUMERO_EMPRESA + ', Bairro ' + #CONSULTA1.BAIRRO_EMPRESA + ', CEP ' + #CONSULTA1.CEP_EMPRESA + ', na cidade de ' + #CONSULTA1.MUNICIPIO_EMPRESA + ' – ' + #CONSULTA1.ESTADO_EMPRESA + ', resolvem celebrar o presente convênio, que será regido pela Lei nº 11.788, de 25/09/08, mediante as seguintes cláusulas e condições:'
        AS INTRO,

        'CLÁUSULA 1ª - DO OBJETO, DA CLASSIFICAÇÃO E DAS RELAÇÕES DE ESTÁGIO'
        AS TITULO1,
        '1.1.   O presente convênio tem por objetivo regular as relações entre as partes ora conveniadas no que tange à concessão de estágio curricular supervisionado para estudantes regularmente matriculados e que venham frequentando efetivamente cursos oferecidos pelo CENTRO UNIVERSITÁRIO PARAÍSO, nos termos da Lei nº 11.788, de 25 de setembro de 2008.' + CHAR(10) +
        '1.2.   Para os fins deste convênio, entende-se como estágio as atividades proporcionadas ao aluno de graduação, em situações reais da profissão e do trabalho, ligadas à sua área de formação no CENTRO UNIVERSITÁRIO PARAÍSO e previstas no Projeto Pedagógico do Curso.' + CHAR(10) +
        '1.3.   O estágio obrigatório não cria vínculo empregatício de qualquer natureza.'
        AS CLAUSULA1,

        'CLÁUSULA 2ª - DAS COMPETÊNCIAS DO CENTRO UNIVERSITÁRIO PARAÍSO'
        AS TITULO2,
        '2.1.   Celebrar, através da Coordenadoria de Estágios/Coordenadoria de Graduação dos Cursos, Termo de Compromisso de Estágio com a parte CONCEDENTE e o aluno.' + CHAR(10) +
        '2.2.   Avaliar as instalações da parte CONCEDENTE e a sua adequação à formação cultural e profissional do aluno.' + CHAR(10) +
        '2.3.   Indicar um professor orientador da área a ser desenvolvida no estágio como responsável pelo acompanhamento e avaliação das atividades do estagiário.' + CHAR(10) +
        '2.4.   Exigir do estagiário, em prazo não superior a um semestre acadêmico, relatório de atividades conforme estabelecido no termo de compromisso e nas normas do curso. O relatório deve ser entregue pelo aluno ao Coordenador de Estágios do curso devidamente assinado pelas partes envolvidas;' + CHAR(10) +
        '2.5.	Elaborar normas complementares e instrumentos de avaliação dos estágios dos seus educandos;' + CHAR(10) +
        '2.6.	Informar, através de declaração subscrita pelo professor da disciplina, mediante solicitação do aluno, as datas de avaliações escolares ou acadêmicas para fins de redução da carga horária de estágio no período;' + CHAR(10) +
        '2.7.	Zelar pelo cumprimento do Termo de Compromisso de Estágio, reorientando o estagiário para outro local em caso de descumprimento de suas cláusulas por parte da CONCEDENTE.' + CHAR(10) +
        '2.8.	Comunicar à CONCEDENTE os casos de conclusão ou abandono de curso, cancelamento ou trancamento da matrícula.' + CHAR(10) +
        '2.9.	Efetuar, mensalmente, o pagamento do seguro contra acidentes pessoais para o aluno em estágio obrigatório.'
        AS CLAUSULA2,

        'CLÁUSULA 3ª – DAS OBRIGAÇÕES DA CONCEDENTE'
        AS TITULO3,
        'Compete à CONCEDENTE:' + CHAR(10) +
        '3.1.   Conceder estágios ao corpo discente do CENTRO UNIVERSITÁRIO PARAÍSO, observadas a legislação vigente e as disposições deste convênio.' + CHAR(10) +
        '3.2.	Comunicar ao CENTRO UNIVERSITÁRIO PARAÍSO o número de vagas de estágio disponíveis por curso/área de formação, para a devida divulgação e encaminhamento de alunos.' + CHAR(10) +
        '3.3.	Selecionar os estagiários dentre os alunos encaminhados pelo CENTRO UNIVERSITÁRIO PARAÍSO.' + CHAR(10) +
        '3.4.	Celebrar Termo de Compromisso de Estágio com o CENTRO UNIVERSITÁRIO PARAÍSO e com o aluno, zelando pelo seu cumprimento.' + CHAR(10) +
        '3.5.	Ofertar instalações que tenham condições de proporcionar ao educando atividades de aprendizagem social, profissional e cultural, observando o estabelecido na legislação relacionada à saúde e segurança no trabalho.' + CHAR(10) +
        '3.6.	Indicar um funcionário de seu quadro de pessoal, com formação ou experiência profissional na área de conhecimento desenvolvida no curso do estagiário, para orientar e supervisionar as atividades desenvolvidas pelo estagiário. ' + CHAR(10) +
        '3.7.	Zelar para que a carga horária máxima do estagiário corresponda a, no máximo, 6 horas diárias e 30 horas semanais.' + CHAR(10) +
        '3.8.	Assegurar ao estagiário, sempre que o estágio tenha a duração igual ou superior a 1 (um) ano, o período de recesso de 30 (trinta) dias, a ser gozado preferencialmente no período de férias escolares.' + CHAR(10) +
        '3.9.	Encaminhar, por ocasião do desligamento do estagiário, o termo de realização de estágio ao Coordenador de Estágio/de graduação do curso, com a indicação resumida das atividades desenvolvidas, dos períodos e da avaliação de desempenho.  ' + CHAR(10) +
        '3.10.	Informar ao CENTRO UNIVERSITÁRIO PARAÍSO sobre a frequência e o desempenho dos estagiários, observadas as exigências de cada curso, quando for o caso.' + CHAR(10) +
        '3.11.	Indicar CENTRO UNIVERSITÁRIO PARAÍSO, para ser substituído, o estagiário que, por motivo de natureza técnica, administrativa ou disciplinar, não for considerado apto a continuar suas atividades de estágio.'
        AS CLAUSULA3,

        'CLÁUSULA 4ª – DAS COMPETÊNCIAS DO ESTAGIÁRIO'
        AS TITULO4,
        '4.1.   Cumprir o que for proposto no plano de estágio, em conformidade com o professor orientador e supervisor de estágio.' + CHAR(10) +
        '4.2.   Zelar pelos equipamentos, materiais e documentos da empresa.' + CHAR(10) +
        '4.3.   Manter sigilo sobre informações escritas ou verbais da empresa, adotando postura ética profissional.'
        AS CLAUSULA4,

        'CLÁUSULA 5ª – DO DESLIGAMENTO OU SUBSTITUIÇÃO DE ESTÁGIO'
        AS TITULO5,
        'A concedente poderá solicitar, a qualquer momento, o desligamento e/ou a substituição de estagiários nos casos previstos pela legislação vigente, dando ciência à CENTRO UNIVERSITÁRIO PARAÍSO, bem como a própria I.E.S ou o próprio estagiário requerer o desligamento.'
        AS CLAUSULA5,

        'CLÁUSULA 6ª – DO DESLIGAMENTO OU SUBSTITUIÇÃO DO ESTAGIÁRIO'
        AS TITULO6,
        'Qualquer uma das partes pode solicitar o desligamento do estagiário, dando ciência ao CENTRO UNIVERSITÁRIO PARAÍSO quando for por iniciativa da empresa ou do próprio estagiário, no prazo mínimo de 30(trinta) dias.'
        AS CLAUSULA6,

        'CLÁUSULA 7ª – DA VIGÊNCIA'
        AS TITULO7,
        'O presente convênio terá vigência de 24 (vinte e quatro) meses, a partir da data de sua assinatura, podendo ser prorrogado automaticamente, a cada ano, se nenhuma das partes se pronunciarem em contrário, até 30 (trinta) dias antes do término.'
        AS CLAUSULA7,
        
        'CLÁUSULA 8ª – DA RESCISÃO'
        AS TITULO8,
        'Este convênio poderá ser denunciado pelas partes a qualquer tempo, mediante correspondência que antecederá 30 (trinta) dias, no mínimo, à vigência da cessação do presente pacto, indicando as razões da denúncia.' + CHAR(10) +
        'E por estarem concordes, as partes signatárias deste instrumento elegem o município de Juazeiro do Norte - CE para dirimir eventuais pendências e subscrevem-se em duas vias de igual teor e forma.'
        AS CLAUSULA8,

        NULL
        AS TITULO9,
        NULL
        AS CLAUSULA9
FROM #CONSULTA1

/* Estágio NÃO-OBRIGATÓRIO */
ELSE IF ((@IDTURMADISC IS NULL) AND (@ESTAGIOOBRIGATORIO = 'N' OR @ESTAGIOOBRIGATORIO IS NULL))
SELECT
	'Estágio NÃO-OBRIGATÓRIO'
	AS TIPO,

	'CONVÊNIO'
	AS TITULO,

    'Convênio que celebram entre si o Educacional Fiúsa S/S Ltda, CNPJ nº 04.242.942/0001-37, na qualidade de mantenedor do CENTRO UNIVERSITÁRIO PARAÍSO, instituição de ensino superior, com sede à Rua São Benedito, 344 – São Miguel – Juazeiro do Norte, CEP 63010-220, Estado do Ceará, doravante denominado CENTRO UNIVERSITÁRIO PARAÍSO e ' + #CONSULTA1.NOME_EMPRESA + ' CNPJ nº ' + #CONSULTA1.CNPJ + ', localizada ' + #CONSULTA1.RUA_EMPRESA + ', ' + #CONSULTA1.NUMERO_EMPRESA + ', ' + #CONSULTA1.BAIRRO_EMPRESA + ', ' + #CONSULTA1.MUNICIPIO_EMPRESA + ', ' + #CONSULTA1.ESTADO_EMPRESA + ', doravante denominada EMPRESA com o fim de colaborarem, reciprocamente, no planejamento, execução e avaliação dos Estágios Não-Obrigatórios, conforme o que determina a Lei nº 11.788, de 25/09/2008.'
    AS PREINTRO,

	'O CENTRO UNIVERSITÁRIO PARAÍSO, doravante denominada CENTRO UNIVERSITÁRIO, neste ato representada por seu Reitor, João Luis Alexandre Fiúsa e ' + #CONSULTA1.NOME_EMPRESA + ' doravante denominada EMPRESA, neste ato representada por Sr.(a) ' + #CONSULTA1.RESPONSAVEL + ' têm justo e acertado o consubstanciado nas seguintes cláusulas:'
	AS INTRO,

	'CLÁUSULA 1ª – DOS OBJETIVOS DO ESTÁGIO CURRICULAR SUPERVISIONADO'
	AS TITULO1,
	'O presente convênio objetiva estabelecer as condições para a realização dos estágios não-obrigatórios, observando o preceituado na Lei nº 11.788, de 25/09/2008.'
	AS CLAUSULA1,

	'CLÁUSULA 2ª – DAS COMPETÊNCIAS DA EMPRESA'
	AS TITULO2,
	'Considera-se estágio o ato educativo acadêmico supervisionado, desenvolvido no ambiente de trabalho e relacionado à área de formação do educando. Caracteriza-se como não-obrigatório por ser opcional, de iniciativa do estudante e pode ser contabilizado como atividades complementares no Centro Universitário Paraíso.'
	AS CLAUSULA2,

	'CLÁUSULA 3ª – DAS COMPETÊNCIAS DO CENTRO UNIVERSITÁRIO'
	AS TITULO3,
	'O estágio não-obrigatório tem como finalidade a aprendizagem de competências próprias da atividade profissional e o desenvolvimento do educando para a vida cidadã e para o trabalho.'
	AS CLAUSULA3,

	'CLÁUSULA 4ª - DAS COMPETÊNCIAS DO(A) ESTAGIÁRIO(A)'
	AS TITULO4,
	'I - promover o cadastramento e encaminhar candidatos a estágio, segundo critérios de perfil propostos pela empresa;' + CHAR(10) +
    'II - preparar em nível preliminar, os universitários para o estágio, sensibilizando-os sobre a oportunidade de adquirirem os conhecimentos práticos, dentro do contexto da atividade produtiva e orientando-os para sua inserção na hierarquia empresarial e para a prática da disciplina na empresa; ' + CHAR(10) +
    'III -  encaminhar à EMPRESA os estudantes do curso solicitado a partir dos critérios de semestre;' + CHAR(10) +
    'IV – indicar professor orientador da área a ser desenvolvida no estágio, como responsável pelo acompanhamento e avaliação das atividades de estágio;' + CHAR(10) +
    'V- articular-se com a Empresa com o objetivo de compatibilizar a orientação decorrente da ótica do ensino, com a orientação sob o ponto de vista da produção, mediante entrosamento entre o professor orientador, designado pelo CENTRO UNIVERSITÁRIO PARAÍSO, e o supervisor do estágio designado pela EMPRESA, para assistir ao estagiário;' + CHAR(10) +
    'VI - proceder com a organização e a avaliação periódica do estágio, através de relatórios de atividades, com periodicidade semestral;' + CHAR(10) +
    'VII – celebrar o Termo de Compromisso com o educando e a empresa;' + CHAR(10) +
    'VIII – preparar ou subsidiar a empresa na elaboração do plano de atividades de estágio;' + CHAR(10) +
    'IX - avaliar as instalações da parte concedente do estágio e sua adequação à formação do educando;' + CHAR(10) +
    'X – comunicar à empresa, no início do período letivo, a data de realização das avaliações periódicas, conforme Calendário Acadêmico.'
	AS CLAUSULA4,

	'CLÁUSULA 5ª – DAS DISPOSIÇÕES GERAIS'
	AS TITULO5,
	'I - definir sua política de estágio planejando adequadamente o estágio de estudantes em seus quadros;' + CHAR(10) +
    'II - oferecer oportunidades de estágio na área de formação do estagiário;' + CHAR(10) +
    'III - receber os estudantes triados e encaminhados pelo CENTRO UNIVERSITÁRIO PARAÍSO;' + CHAR(10) +
    'IV - supervisionar as atividades realizadas pelos estagiários, indicando funcionário do seu quadro de pessoal, com formação ou experiência profissional na área de conhecimento do estagiário, para supervisionar até 10(dez) estagiários simultaneamente;' + CHAR(10) +
    'V - permitir o acesso de representantes credenciados do CENTRO UNIVERSITÁRIO PARAÍSO ao local de estágio, segundo periodicidade a ser estabelecida pelo CENTRO UNIVERSITÁRIO objetivando o acompanhamento e a avaliação do estágio;' + CHAR(10) +
    'VI - firmar o Termo de Compromisso com o estagiário, com a interveniência do CENTRO UNIVERSITÁRIO PARAÍSO;' + CHAR(10) +
    'VII - oferecer instalações que propiciem ao educando atividades de aprendizagem profissional, social e cultural.' + CHAR(10) +
    'VIII - enviar ao CENTRO UNIVERSITÁRIO PARAÍSO relatório de atividades com vista obrigatória ao estagiário, pelo menos a cada seis meses;' + CHAR(10) +
    'IX - contratar em favor do estagiário seguro contra acidentes pessoais, com apólice compatível com valores de mercado e especificar no Termo de Compromisso de Estágio;' + CHAR(10) +
    'X - observar a duração do estágio que não poderá exceder 02(dois) anos, exceto quando se tratar de estagiário portador de deficiência;' + CHAR(10) +
    'XI - fazer constar  e cumprir a jornada do estágio no Termo de Compromisso de Estágio, sendo esta compatível com as atividades acadêmicas e não ultrapassando 06(seis) horas diárias e 30(trinta) horas semanais;' + CHAR(10) +
    'XII - reduzir a carga horária do estágio pelo menos à metade, no período de avaliações calendarizadas pela CENTRO UNIVERSITÁRIO PARAÍSO;' + CHAR(10) +
    'XIII - conceder ao estagiário pagamento de bolsa-auxílio ou outra forma de contraprestação, além do auxílio transporte;' + CHAR(10) +
    'XIV - assegurar ao estagiário, período de recesso remunerado de 30(trinta) dias, a ser gozado, preferencialmente, nos meses de janeiro ou julho, sempre que o estágio tenha duração igual ou superior a 1(um) ano.' + CHAR(10) +
    'Parágrafo único: o estágio não-obrigatório, atendida as cláusulas acima, não gera vínculo empregatício para as partes.'
    AS CLAUSULA5,

	'CLÁUSULA 6ª – DO DESLIGAMENTO OU SUBSTITUIÇÃO DO ESTAGIÁRIO'
    AS TITULO6,
	'Qualquer uma das partes pode solicitar o desligamento do estagiário, dando ciência ao CENTRO UNIVERSITÁRIO PARAÍSO quando for por iniciativa da empresa ou do próprio estagiário, no prazo mínimo de 30(trinta) dias.'
    AS CLAUSULA6,

	'CLÁUSULA 7ª – DA VIGÊNCIA'
    AS TITULO7,
	'O presente convênio terá vigência de 24 (vinte e quatro) meses, a partir da data de sua assinatura, podendo ser prorrogado automaticamente, a cada ano, se nenhuma das partes se pronunciarem em contrário, até 30 (trinta) dias antes do término.'
    AS CLAUSULA7,
	
    'CLÁUSULA 8ª – DA RESCISÃO'
    AS TITULO8,
	'Este convênio poderá ser denunciado pelas partes a qualquer tempo, mediante correspondência que antecederá 30 (trinta) dias, no mínimo, à vigência da cessação do presente pacto, indicando as razões da denúncia.' + CHAR(10) +
    'E por estarem concordes, as partes signatárias deste instrumento elegem o município de Juazeiro do Norte - CE para dirimir eventuais pendências e subscrevem-se em duas vias de igual teor e forma.'
    AS CLAUSULA8,

        NULL
        AS TITULO9,
        NULL
        AS CLAUSULA9
FROM #CONSULTA1

DROP TABLE #CONSULTA1
--SELECT * FROM #CONSULTA1