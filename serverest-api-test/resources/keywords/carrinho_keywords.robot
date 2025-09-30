*** Settings ***
Documentation    Keywords relacionadas ao gerenciamento de carrinhos
Library          RequestsLibrary
Library          Collections
Resource         ../variables.robot
Resource         ../base_setup.robot
Resource         login_keywords.robot
Resource         produtos_keywords.robot

*** Keywords ***
Criar carrinho com produtos
    [Documentation]    Cria um carrinho com lista de produtos
    [Arguments]    ${produtos}    ${token}=${TOKEN}
    
    ${headers}=    Criar Headers Com Token    ${token}
    
    ${body}=    Create Dictionary    produtos=${produtos}
    
    ${response}=    POST    ${BASE_URL}${CARRINHO_ENDPOINT}    json=${body}    headers=${headers}    expected_status=any
    
    RETURN    ${response}

Adicionar produto ao carrinho
    [Documentation]    Adiciona um produto ao carrinho
    [Arguments]    ${produto_id}    ${quantidade}    ${token}=${TOKEN}
    
    ${produto}=    Create Dictionary
    ...    idProduto=${produto_id}
    ...    quantidade=${quantidade}
    
    ${produtos}=    Create List    ${produto}
    
    ${response}=    Criar Carrinho Com Produtos    ${produtos}    ${token}
    
    RETURN    ${response}

Adicionar multiplos produtos ao carriho
    [Documentation]    Adiciona múltiplos produtos ao carrinho
    [Arguments]    ${lista_produtos}    ${token}=${TOKEN}
    
    ${response}=    Criar Carrinho Com Produtos    ${lista_produtos}    ${token}
    
    RETURN    ${response}

Buscar carrinho por ID
    [Documentation]    Busca carrinho específico por ID
    [Arguments]    ${carrinho_id}
    
    ${response}=    GET    ${BASE_URL}${CARRINHO_ENDPOINT}/${carrinho_id}    expected_status=any
    
    RETURN    ${response}

Listar todos os carrinhos
    [Documentation]    Lista todos os carrinhos cadastrados
    
    ${response}=    GET    ${BASE_URL}${CARRINHO_ENDPOINT}    expected_status=200
    
    Validar Status Code    ${response}    ${STATUS_200}
    RETURN  ${response}

Cancelar compra
     [Documentation]    Cancela a compra e deleta o carrinho (retorna produtos ao estoque)
    [Arguments]    ${token}=${TOKEN}
    
    ${headers}=    Criar Headers Com Token    ${token}
    ${response}=    DELETE    ${BASE_URL}${CARRINHO_ENDPOINT}/cancelar-compra    headers=${headers}    expected_status=any
    
    RETURN   ${response}

Concluir compra
    [Documentation]    Conclui a compra e deleta o carrinho
    [Arguments]    ${token}=${TOKEN}
    
    ${headers}=    Criar Headers Com Token    ${token}
    ${response}=    DELETE    ${BASE_URL}${CARRINHO_ENDPOINT}/concluir-compra    headers=${headers}    expected_status=any
    
    RETURN    ${response}

Validar carrinho criado com sucesso
    [Documentation]    Valida resposta de criação de carrinho bem-sucedida
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_201}
    ${response_json}=    Set Variable    ${response.json()}
    
    Dictionary Should Contain Key    ${response_json}    _id
    Dictionary Should Contain Key    ${response_json}    message
    
    Should Be Equal    ${response_json['message']}    Cadastro realizado com sucesso
    ...    msg=Mensagem de sucesso não retornada

Validar erro produto inexistente
    [Documentation]    Valida erro quando produto não existe no carrinho
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Mensagem De Erro    ${response}    Produto não encontrado

Validar erro produto sem estoque
    [Documentation]    Valida erro quando produto não tem quantidade suficiente
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    ${response_json}=    Set Variable    ${response.json()}
    Should Contain    ${response_json['message']}    quantidade
    ...    msg=Mensagem de erro de estoque não encontrada

Validar erro carrinho duplicado
    [Documentation]    Valida erro quando usuário já possui carrinho
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Mensagem De Erro    ${response}    Não é permitido ter mais de 1 carrinho

Validar carrinho nao encontrado
    [Documentation]    Valida erro quando carrinho não existe
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Mensagem De Erro    ${response}    Não foi encontrado carrinho para esse usuário

Validar compra cancelada com sucesso
    [Documentation]    Valida resposta de cancelamento de compra bem-sucedido
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    200
    ${response_json}=    Set Variable    ${response.json()}
    
    Should Contain    ${response_json['message']}    cancelada com sucesso
    ...    msg=Mensagem de cancelamento não retornada

Validar compra conluida com sucesso
    [Documentation]    Valida resposta de conclusão de compra bem-sucedida
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    200
    ${response_json}=    Set Variable    ${response.json()}
    
    Should Contain    ${response_json['message']}    concluída com sucesso
    ...    msg=Mensagem de conclusão não retornada

Validar quantidade no carrinho
    [Documentation]    Valida quantidade de produtos no carrinho
    [Arguments]    ${response}    ${quantidade_esperada}
    
    ${response_json}=    Set Variable    ${response.json()}
    ${quantidade_produtos}=    Get Length    ${response_json['produtos']}
    
    Should Be Equal As Integers    ${quantidade_produtos}    ${quantidade_esperada}
    ...    msg=Quantidade de produtos no carrinho diferente do esperado
    