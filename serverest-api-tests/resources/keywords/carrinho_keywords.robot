*** Settings ***
Documentation    Keywords relacionadas ao gerenciamento de carrinhos
Library          RequestsLibrary
Library          Collections
Resource         ../variables.robot
Resource         ../base_setup.robot
Resource         login_keywords.robot
Resource         produtos_keywords.robot

*** Keywords ***

Criar Carrinho Com Produtos
    [Documentation]    Cria um carrinho com lista de produtos
    [Arguments]    ${produtos}    ${token}=${TOKEN}
    
    ${headers}=    Criar Headers Com Token    ${token}
    
    
    ${body}=    Create Dictionary    produtos=${produtos}
    
    ${response}=    POST    ${BASE_URL}${CARRINHO_ENDPOINT}    json=${body}    headers=${headers}    expected_status=any
    
    RETURN    ${response}

Adicionar Produto Ao Carrinho
    [Documentation]    Cria um carrinho adicionando um único produto
    [Arguments]    ${produto_id}    ${quantidade}    ${token}=${TOKEN}
    
    ${produto}=    Create Dictionary
    ...    idProduto=${produto_id}
    ...    quantidade=${quantidade}
    
    ${produtos}=    Create List    ${produto}
    
    ${response}=    Criar Carrinho Com Produtos    ${produtos}    ${token}
    
    RETURN    ${response}

Adicionar Multiplos Produtos Ao Carrinho
    [Documentation]    Cria um carrinho adicionando uma lista de produtos
    [Arguments]    ${lista_produtos}    ${token}=${TOKEN}
    
    ${response}=    Criar Carrinho Com Produtos    ${lista_produtos}    ${token}
    
    RETURN    ${response}

Buscar Carrinho Por ID
    [Documentation]    Busca um carrinho específico pelo ID (do carrinho, não do usuário).
    [Arguments]    ${carrinho_id}
    
    ${response}=    GET    ${BASE_URL}${CARRINHO_ENDPOINT}/${carrinho_id}    expected_status=any
    
    RETURN    ${response}

Listar Carrinhos
    [Documentation]    Busca a lista de todos os carrinhos cadastrados.
    
    ${response}=    GET    ${BASE_URL}${CARRINHO_ENDPOINT}    expected_status=any
    
    RETURN    ${response}

Concluir Compra
    [Documentation]    Finaliza o carrinho do usuário logado (DELETE /carrinhos/concluir-compra).
    [Arguments]    ${token}=${TOKEN}
    
    ${headers}=    Criar Headers Com Token    ${token}
    
    ${response}=    DELETE    ${BASE_URL}${CARRINHO_ENDPOINT}/concluir-compra    headers=${headers}    expected_status=any
    
    RETURN    ${response}

Cancelar Compra
    [Documentation]    Cancela o carrinho do usuário logado (DELETE /carrinhos/cancelar-compra).
    [Arguments]    ${token}=${TOKEN}
    
    ${headers}=    Criar Headers Com Token    ${token}
    
    ${response}=    DELETE    ${BASE_URL}${CARRINHO_ENDPOINT}/cancelar-compra    headers=${headers}    expected_status=any
    
    RETURN    ${response}


Validar Carrinho Criado Com Sucesso
    [Documentation]    Valida resposta de criação de carrinho bem-sucedida (Status 201).
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_201}
    ${response_json}=    Set Variable    ${response.json()}
    
    Dictionary Should Contain Key    ${response_json}    _id
    Dictionary Should Contain Key    ${response_json}    message
    
    Should Be Equal    ${response_json['message']}    Cadastro realizado com sucesso
    ...    msg=Mensagem de criação de carrinho incorreta

Validar Erro Carrinho Nao Encontrado
    [Documentation]    Valida erro quando carrinho não existe para o usuário (Status 400).
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Mensagem De Erro    ${response}    Não foi encontrado carrinho para esse usuário

Validar Erro De Produto Inexistente
    [Documentation]    Valida erro ao adicionar produto com ID inválido ou inexistente (Status 400).
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Mensagem De Erro    ${response}    Produto não encontrado

Validar Erro Quantidade Indisponivel
    [Documentation]    Valida erro quando a quantidade excede o estoque (Status 400).
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Mensagem De Erro    ${response}    Produto não possui quantidade suficiente

Validar Compra Cancelada Com Sucesso
    [Documentation]    Valida resposta de cancelamento de compra bem-sucedido (Status 200).
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_200}
    ${response_json}=    Set Variable    ${response.json()}
    
    Should Contain    ${response_json['message']}    cancelada com sucesso
    ...    msg=Mensagem de cancelamento não retornada

Validar Compra Concluida Com Sucesso
    [Documentation]    Valida resposta de conclusão de compra bem-sucedida (Status 200).
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_200}
    ${response_json}=    Set Variable    ${response.json()}
    
    Should Contain    ${response_json['message']}    concluída com sucesso
    ...    msg=Mensagem de conclusão não retornada
