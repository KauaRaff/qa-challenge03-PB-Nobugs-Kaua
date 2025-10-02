*** Settings ***
Documentation    Testes de criação e validação de usuários da API ServeRest
Resource         ../../../resources/base_setup.robot
Resource         ../../../resources/variables.robot
Resource         ../../../resources/keywords/usuarios_keywords.robot

Suite Setup      Setup Suite
Suite Teardown   Teardown Suite
Test Setup       Setup Test
Test Teardown    Teardown Test

*** Test Cases ***
CT001 - Criar usuário com dados válidos
    [Documentation]    Valida criação de usuário com todos os campos corretos
    [Tags]    usuarios    smoke    high
    
    ${email}=    Gerar Email Aleatorio
    ${nome}=     Gerar Nome Aleatorio
    
    ${response}=    Criar Usuario Com Dados    ${nome}    ${email}    teste123    false
    Validar Usuario Criado Com Sucesso    ${response}

CT002 - Criar usuário administrador
    [Documentation]    Valida criação de usuário com perfil de administrador
    [Tags]    usuarios    smoke    high
    
    ${email}=    Gerar Email Aleatorio
    ${nome}=     Gerar Nome Aleatorio
    
    ${response}=    Criar Usuario Com Dados    ${nome}    ${email}    teste123    true
    Validar Usuario Criado Com Sucesso    ${response}

CT003 - Criar usuário sem nome
    [Documentation]    Valida erro quando campo nome não é enviado
    [Tags]    usuarios    negative    validation    high
    
    ${email}=    Gerar Email Aleatorio
    
    ${body}=    Create Dictionary    email=${email}    password=teste123    administrador=false
    ${response}=    POST    ${BASE_URL}${USUARIOS_ENDPOINT}    json=${body}    expected_status=400
    
    Validar Erro Campo Obrigatorio Usuario    ${response}    nome

CT004 - Criar usuário sem email
    [Documentation]    Valida erro quando campo email não é enviado
    [Tags]    usuarios    negative    validation    high
    
    ${nome}=    Gerar Nome Aleatorio
    
    ${body}=    Create Dictionary    nome=${nome}    password=teste123    administrador=false
    ${response}=    POST    ${BASE_URL}${USUARIOS_ENDPOINT}    json=${body}    expected_status=400
    
    Validar Erro Campo Obrigatorio Usuario    ${response}    email

CT005 - Criar usuário sem senha
    [Documentation]    Valida erro quando campo senha não é enviado
    [Tags]    usuarios    negative    validation    high
    
    ${email}=    Gerar Email Aleatorio
    ${nome}=     Gerar Nome Aleatorio
    
    ${body}=    Create Dictionary    nome=${nome}    email=${email}    administrador=false
    ${response}=    POST    ${BASE_URL}${USUARIOS_ENDPOINT}    json=${body}    expected_status=400
    
    Validar Erro Campo Obrigatorio Usuario    ${response}    password

CT006 - Criar usuário com email inválido
    [Documentation]    Valida erro quando email está em formato incorreto
    [Tags]    usuarios    negative    validation    medium
    
    ${nome}=    Gerar Nome Aleatorio
    
    ${response}=    Criar Usuario Com Dados    ${nome}    emailinvalido    teste123    false
    Validar Email Invalido    ${response}

CT007 - Criar usuário com email sem @
    [Documentation]    Valida erro quando email não contém @
    [Tags]    usuarios    negative    validation    medium
    
    ${nome}=    Gerar Nome Aleatorio
    
    ${response}=    Criar Usuario Com Dados    ${nome}    emailsemarrobagmail.com    teste123    false
    Validar Email Invalido    ${response}

CT008 - Criar usuário com senha curta
    [Documentation]    Valida comportamento com senha muito curta
    [Tags]    usuarios    negative    validation    medium
    
    ${email}=    Gerar Email Aleatorio
    ${nome}=     Gerar Nome Aleatorio
    
    ${response}=    Criar Usuario Com Dados    ${nome}    ${email}    12    false
    # API pode aceitar ou rejeitar dependendo da regra de negócio
    Validar Status Code    ${response}    ${STATUS_400}

CT009 - Criar usuário com caracteres especiais no nome
    [Documentation]    Valida comportamento ao usar caracteres especiais no nome
    [Tags]    usuarios    negative    validation    medium
    
    ${email}=    Gerar Email Aleatorio
    ${nome_especial}=    Set Variable    Usuario @#$% Teste
    
    ${response}=    Criar Usuario Com Dados    ${nome_especial}    ${email}    teste123    false
    # Verifica se API aceita ou rejeita caracteres especiais
    ${status}=    Set Variable    ${response.status_code}
    Run Keyword If    ${status} == 201    Log To Console    API aceita caracteres especiais no nome
    ...    ELSE    Log To Console    API rejeita caracteres especiais no nome