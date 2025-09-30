*** Settings ***
Documentation        Configurações base para todos os testes da API ServeRest
Library        RequestsLibrary
Library        Collections
Library        String
Resource        variables.robot


*** Keywords ***
Setup suite
    [Documentation]        Configuração executada uma vez antes de todos os testes da suite
    Create Session    alias=serverest    url=${BASE_URL}    verify=True
    Log To Console     Sessão HTTP criada com sucesso para ${BASE_URL}

Teardown suite
    [Documentation]        Limpeza executada após todos os testes da suite
    Delete All Sessions        
    Log To Console        Todas as sessões foram encerradas

Validar status code
    [Documentation]        Valida se o status code da resposta é o esperado
    [Arguments]        ${response}        ${expected_status}
    Should Be Equal As Integers    ${response.status_code}    ${expected_status}    
...    msg=Status code esperado: ${expected_status}, mas recebeu: ${response.status_code}

Validar mensagem de erro
    [Documentation]        Valida se a mensagem de erro está presente na resposta
    [Arguments]        ${response}        ${mensagem_esperada}
    ${response_json}=    Set Variable    ${response.json()}
    Should Contain    ${response_json['message']}        ${mensagem_esperada}
...    msg=Mensagem esperada não encontrada na resposta

Validar campo obrigatorio
    [Documentation]    Valida se campo obrigatório está presente na resposta
    [Arguments]    ${response}    ${campo}
    ${response_json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${response_json}    ${campo}
  ...    msg=Campo obrigatório '${campo}' não encontrado na resposta

Gerar Email Aleatorio
    [Documentation]    Gera um email aleatório para testes
    ${timestamp}=    Get Time    epoch
    ${email}=    Set Variable    teste${timestamp}@qa.com
    RETURN        ${email}

Gerar Nome Aleatorio
    [Documentation]    Gera um nome aleatório para testes
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Usuario Teste ${timestamp}
    RETURN    ${nome}