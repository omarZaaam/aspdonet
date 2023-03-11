#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
ENV ASPNETCORE_URLS http://+:8000
EXPOSE 8080


FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["testproject/testproject.csproj", "testproject/"]
RUN dotnet restore "testproject/testproject.csproj"
COPY . .
WORKDIR "/src/testproject"
RUN dotnet build "testproject.csproj" -c Release -o /app/build

FROM build AS publish
RUN echo "Creating development certifiate......"
RUN dotnet dev-certs https
RUN dotnet publish "testproject.csproj" -c Release -o /app/publish /p:UseAppHost=false^M

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "testproject.dll"]
