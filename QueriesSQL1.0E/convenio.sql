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
        SEMPRESA.NOME				[NOME_EMPRESA],				
        SEMPRESA.NOMEFANTASIA		[NOMEFANTASIA_EMPRESA],		
        FUNCIONARIOS.CARTIDENTIDADE,
        FUNCIONARIOS.UFCARTIDENT,
        SEMPRESA.CEP				[CEP_EMPRESA],
        SEMPRESA.RUA				[RUA_EMPRESA],	
        SEMPRESA.NUMERO				[NUMERO_EMPRESA],
        SEMPRESA.BAIRRO				[BAIRRO_EMPRESA],
        GMUNICIPIO.NOMEMUNICIPIO	[MUNICIPIO_EMPRESA],
        GMUNICIPIO.CODETDMUNICIPIO	[ESTADO_EMPRESA],
        SEMPRESA.CNPJ,
        SUPERVISOR.NOME				[SUPERVISOR],
        FUNCIONARIOS.NOME			[RESPONSAVEL],
        SUPERVISOR.CPF				[CPF_SUPERVISOR],
        SUPERVISOR.TELEFONE			[TEL_SUPERVISOR],
        SUPERVISOR.EMAIL			[EMAIL_SUPERVISOR],
        SUPERVISOR.CARGO			[CARGO_SUPERVISOR],
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


/* Estágio OBRIGATÓRIO com EMPRESA */
IF ((@IDTURMADISC IS NULL) AND (@ESTAGIOOBRIGATORIO = 'N' OR @ESTAGIOOBRIGATORIO IS NULL))
    SELECT
        'CONVÊNIO'
        AS TITULO,

        'Convênio que celebram entre si o Educacional Fiúsa S/S Ltda, CNPJ nº 04.242.942/0001-37, na qualidade de mantenedor do CENTRO UNIVERSITÁRIO PARAÍSO, instituição de ensino superior, com sede à Rua São Benedito, 344 – São Miguel – Juazeiro do Norte, CEP 63010-220, Estado do Ceará, doravante denominado CENTRO UNIVERSITÁRIO PARAÍSO e ' + #CONSULTA1.NOME_EMPRESA + ' CNPJ nº ' + #CONSULTA1.CNPJ + ', localizada a ' + #CONSULTA1.RUA_EMPRESA + ', ' + #CONSULTA1.NUMERO_EMPRESA + ', ' + #CONSULTA1.BAIRRO_EMPRESA + ', ' + #CONSULTA1.MUNICIPIO_EMPRESA + ', ' + #CONSULTA1.ESTADO_EMPRESA + ', doravante denominada EMPRESA com o fim de colaborarem, reciprocamente, no planejamento, execução e avaliação dos Estágios Não-Obrigatórios, conforme o que determina a Lei nº 11.788, de 25/09/2008.'
        AS PREINTRO,

        'O CENTRO UNIVERTÁRIO PARAÍSO, doravante denominada CENTRO UNIVERSITÁRIO, neste ato representada por seu Reitor, João Luis Alexandre Fiúsa e ' + #CONSULTA1.NOME_EMPRESA + ' doravante denominada EMPRESA, neste ato representada por Sr.(a) ' + #CONSULTA1.RESPONSAVEL + ' têm justo e acertado o consubstanciado nas seguintes cláusulas:'
        AS INTRO,

        'CLÁUSULA 1ª - DO OBJETIVO DO CONVÊNIO'
        AS TITULO1,
        'O presente convênio objetiva estabelecer as condições para a realização dos estágios não-obrigatórios, observando o preceituado na Lei nº 11.788, de 25/09/2008.'
        AS CLAUSULA1,

        'CLÁUSULA 2ª - DA NATUREZA DO ESTÁGIO NÃO-OBRIGATÓRIO'
        AS TITULO2,
        'I – designar supervisor de estágio que deverá ter formação ou experiência na área de atuação do ESTAGIÁRIO (A), respeitando o limite de supervisão de até 10(dez) estagiários simultaneamente;' + CHAR(10) +
        'II – proceder, a qualquer momento, mediante a indicação explicita das razões, o desligamento ou substituição do (a) ESTAGIÁRIO (A), dando ciência por escrito da ocorrência ao coordenador de estágio do CENTRO UNIVERSITÁRIO PARAÍSO;' + CHAR(10) +
        'III - possibilitar o acesso do(a) professor(a) orientador(a) pelo CENTRO UNIVERSITÁRIO PARAÍSO que visitará o local de estágio quando necessário;' + CHAR(10) +
        'IV – A empresa concederá bolsa-auxílio no valor de R$ ' + #CONSULTA1.VLRBOLSA + ' e R$ ' + #CONSULTA1.VLRBENEFICIOS + ' referente ao auxílio transporte.' + CHAR(10) +
        'V – O seguro contra acidentes pessoais em favor do estagiário foi realizado pela Seguradora ' + #CONSULTA1.NOMECIASEGUROS + ', cuja apólice é de nº ' + #CONSULTA1.NRAPOLICE + '.' + CHAR(10) +
        'VI – Reduzir a carga horária do estágio pelo menos à metade, no período de avaliações calendarizadas pela FACULDADE PARAÍSO, mediante comprovação através do Calendário Acadêmico;' + CHAR(10) +
        'VII – Assegurar ao estagiário, período de recesso remunerado de 30(trinta) dias, a ser gozado, preferencialmente, nos meses de janeiro ou julho, sempre que o estágio tenha duração igual ou superior a 1(um) ano.'
        AS CLAUSULA2,

        'CLÁUSULA 3º - DA FINALIDADE DO ESTÁGIO NÃO-OBRIGATÓRIO'
        AS TITULO3,
        'I - Preparar, em nível preliminar, os (as) universitários (as) para o estágio;' + CHAR(10) +
        'II - Designar, como professor(a) orientador(a) o (a) Prof (a). ' + #CONSULTA1.ORIENTADOR + ' a quem caberá acompanhamento, orientação e avaliação do (a) ESTAGIÁRIO (A), bem como poderá visitar a EMPRESA conforme item III da Cláusula 2ª;' + CHAR(10) +
        'III - Manter atualizadas as informações cadastrais relativas ao Estagiário;' 
        AS CLAUSULA3,

        'CLÁUSULA 4ª - DAS COMPETÊNCIAS DO CENTRO UNIVERSITÁRIO'
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

        'CLÁUSULA 5ª - DAS COMPETÊNCIAS DA EMPRESA'
        AS TITULO5,
        'I - o(a) ESTAGIÁRIO(A) não terá, para quaisquer efeitos, vínculo empregatício com a EMPRESA, conforme o artigo 3º da Lei nº 11.788, de 25/09/2008.' + CHAR(10) +
        'Parágrafo único. E por estarem concordes, as partes signatárias deste instrumento elegem o foro do município de Juazeiro do Norte (CE) para dirimir eventuais pendências e subscrevem-no em três vias de igual teor, ficando uma via sob a guarda do ESTAGIÁRIO (A), outra com a EMPRESA e outra com o CENTRO UNIVERSITÁRIO PARAÍSO.'
        AS CLAUSULA5,

        'CLÁUSULA 6ª – DO DESLIGAMENTO OU SUBSTITUIÇÃO DO ESTAGIÁRIO'
        AS TITULO6,
        NULL
        AS CLAUSULA6,

        'CLÁUSULA 7ª – DA VIGÊNCIA'
        AS TITULO7,
        NULL
        AS CLAUSULA7,

        'CLÁUSULA 8ª – DA RESCISÃO'
        AS TITULO8,
        NULL
        AS CLAUSULA8,

        NULL AS TITULO9,
        NULL AS CLAUSULA9
FROM #CONSULTA1

/* Estágio OBRIGATÓRIO com PROFISSIONAL LIBERAL */
ELSE IF ((@IDTURMADISC IS NOT NULL) AND (@ESTAGIOOBRIGATORIO = 'S') AND (@CATEGORIA = 5))
    SELECT
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

        'CLÁUSULA 6ª – DA VIGÊNCIA'
        AS TITULO6,
        'O presente convênio terá vigência de 02 anos (dois anos), a partir da data de sua assinatura, podendo ser prorrogado automaticamente, a cada ano, se nenhuma das partes se pronunciarem em contrário, até 30 (trinta) dias antes do término.'
        AS CLAUSULA6,

        'CLÁUSULA 7ª –  DA RESCISÃO'
        AS TITULO7,
        'Este convênio poderá ser denunciado por qualquer das partes a qualquer tempo, mediante correspondência que antecederá 30 (trinta) dias, no mínimo, à vigência da cessação do presente pacto, indicando as razões da denúncia.' + CHAR(10) +
        'E por estarem concordes, as partes signatárias deste instrumento elegem o foro da cidade de Juazeiro do Norte (CE) para dirimir eventuais pendências e subscrevem-se em duas vias de igual teor e forma.'
        AS CLAUSULA7,

        NULL
        AS TITULO8,
        NULL
        AS CLAUSULA8,

        NULL
        AS TITULO9,
        NULL
        AS CLAUSULA9
FROM #CONSULTA1

/* Estágio NÃO-OBRIGATÓRIO */
ELSE IF ((@IDTURMADISC IS NOT NULL) AND (@ESTAGIOOBRIGATORIO = 'S') AND (@CATEGORIA <> 5))
SELECT
	'CONVÊNIO'
	AS TITULO,

    ''
    AS PREINTRO,

	''
	AS INTRO,

	'CLÁUSULA 1ª – DOS OBJETIVOS DO ESTÁGIO CURRICULAR SUPERVISIONADO'
	AS TITULO1,
	''
	AS CLAUSULA1,

	'CLÁUSULA 2ª – DAS COMPETÊNCIAS DA EMPRESA'
	AS TITULO2,
	''
	AS CLAUSULA2,

	'CLÁUSULA 3ª – DAS COMPETÊNCIAS DO CENTRO UNIVERSITÁRIO'
	AS TITULO3,
	''
	AS CLAUSULA3,

	'CLÁUSULA 4ª - DAS COMPETÊNCIAS DO(A) ESTAGIÁRIO(A)'
	AS TITULO4,
	''
	AS CLAUSULA4,

	'CLÁUSULA 5ª – DAS DISPOSIÇÕES GERAIS'
	AS TITULO5,
	''
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