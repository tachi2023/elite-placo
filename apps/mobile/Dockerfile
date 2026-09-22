# Ce Dockerfile sert à construire l'application Flutter Web.
# Il n'est pas recommandé pour Android direct car il nécessite un SDK complet.
FROM cirrusci/flutter:stable AS build
WORKDIR /app
ARG API_BASE_URL=https://elite-placo-api.onrender.com
COPY pubspec.* ./
RUN flutter pub get
COPY . ./
RUN flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
