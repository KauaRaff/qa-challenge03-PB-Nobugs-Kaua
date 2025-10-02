*** Settings ***
Documentation    Configurações base para todos os testes da API ServeRest
Library          RequestsLibrary
Library          Collections
Library          String
Resource         variables.robot

*** Keywords ***
Setup Suite
    [Documentation]    Configuração inicial da suite
    Create Session    alias=serverest    url=${BASE_URL}    verify=True

Teardown Suite
    [Documentation]    Limpeza final da suite
    Delete All Sessions

Validar Status Code
    [Documentation]    Valida status code da resposta
    [Arguments]    ${response}    ${expected_status}
    Should Be Equal As Integers    ${response.status_code}    ${expected_status}

Validar Mensagem De Erro
    [Documentation]    Valida mensagem de erro na resposta
    [Arguments]    ${response}    ${mensagem_esperada}
    ${response_json}=    Set Variable    ${response.json()}
    Should Contain    ${response_json['message']}    ${mensagem_esperada}

Validar Mensagem De Sucesso
    [Documentation]    Valida mensagem de sucesso na resposta
    [Arguments]    ${response}    ${mensagem_esperada}
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json['message']}    ${mensagem_esperada}

Gerar Email Aleatorio
    [Documentation]    Gera email aleatório para testes
    ${timestamp}=    Get Time    epoch
    ${email}=    Set Variable    teste${timestamp}@qa.com
    RETURN    ${email}

Gerar Nome Aleatorio
    [Documentation]    Gera nome aleatório para testes
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Usuario Teste ${timestamp}
    RETURN    ${nome}
