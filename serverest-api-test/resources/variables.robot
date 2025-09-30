*** Variables ***

${BASE_URL}        https://compassuol.serverest.dev/

#endpoints
${LOGIN_ENDPOINT}        https://compassuol.serverest.dev/login
${USUARIOS_ENDPOINT}        https://compassuol.serverest.dev/usuarios
${PRODUTOS_ENDPOINT}        https://compassuol.serverest.dev/produtos
${CARRINHO_ENDPOINT}        https://compassuol.serverest.dev/carrinhos

#dados para teste - admin
${ADMIN_EMAIL}        kaua@qa.com
${ADMIN_PASSWORD}        teste123
${ADMIN_NOME}        kauaqa

#headers
&{HEADERS}        Content-Type=application/json

#status code
${STATUS_200}          200
${STATUS_201}          201
${STATUS_400}          400
${STATUS_404}          404