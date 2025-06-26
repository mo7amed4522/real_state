# Use the .NET 8 SDK image to build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy the project file and restore dependencies
COPY ["dotnet_service.csproj", "."]
RUN dotnet restore "./dotnet_service.csproj"

# Copy the remaining source code and build the application
COPY . .
WORKDIR "/src/."
RUN dotnet build "dotnet_service.csproj" -c Release -o /app/build

# Use the ASP.NET 8 runtime image to run the application
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS publish
WORKDIR /app
COPY --from=build /app/build .
ENTRYPOINT ["dotnet", "dotnet_service.dll"]

CMD ["dotnet", "watch", "run", "--urls", "http://0.0.0.0:8080"] 