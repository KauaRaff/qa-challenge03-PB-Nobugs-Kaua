*** Variables ***
# API Base
${BASE_URL}                 https://serverest.dev

# Endpoints
${LOGIN_ENDPOINT}           /login
${USUARIOS_ENDPOINT}        /usuarios
${PRODUTOS_ENDPOINT}        /produtos
${CARRINHO_ENDPOINT}        /carrinhos

# Admin User
${ADMIN_EMAIL}              kaua123@gmail.com
${ADMIN_PASSWORD}           teste123
${ADMIN_NOME}               kauaqa

# Headers
&{HEADERS}                  Content-Type=application/json

# Status Codes
${STATUS_200}               200
${STATUS_201}               201
${STATUS_400}               400
${STATUS_404}               404