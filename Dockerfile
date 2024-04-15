FROM node:18.20.1-alpine3.19 AS development
RUN corepack enable

WORKDIR /usr/app

COPY pnpm-lock.yaml package.json ./

RUN pnpm install

COPY . .

RUN pnpm build

FROM node:18.20.1-alpine3.19 AS production
RUN corepack enable

WORKDIR /usr/app

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

COPY pnpm-lock.yaml package.json ./

RUN pnpm install

COPY --from=development /usr/app/next.config.js ./
COPY --from=development /usr/app/public ./public
COPY --from=development /usr/app/.next ./.next

EXPOSE 3000

ENV PORT 3000

CMD [ "pnpm", "run", "db:seed" ]