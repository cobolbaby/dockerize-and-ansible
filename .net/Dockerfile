FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -r linux-x64 --self-contained false --no-restore

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/sdk:3.1
WORKDIR /app
COPY --from=build-env /app/bin/Release/netcoreapp3.1/linux-x64/ .
ENTRYPOINT ["dotnet", "PrintAgent.WebApp.dll"]
