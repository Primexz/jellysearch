FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src

COPY src/JellySearch/JellySearch.csproj src/JellySearch/
RUN dotnet restore src/JellySearch/JellySearch.csproj

COPY src/JellySearch/ src/JellySearch/
RUN dotnet publish src/JellySearch/JellySearch.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 as production

ENV JELLYFIN_URL=http://jellyfin:8096 \
    JELLYFIN_CONFIG_DIR=/config \
    MEILI_URL=http://meilisearch:7700

WORKDIR /app

COPY --from=build --chown=1000:100 /app/publish .

EXPOSE 5000

USER 1000:100

ENTRYPOINT ["dotnet", "jellysearch.dll"]
