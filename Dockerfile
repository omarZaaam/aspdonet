#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
ENV ASPNETCORE_URLS http://+:8000;https://+:8443
EXPOSE 8080
EXPOSE 8443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["testproject/testproject.csproj", "testproject/"]
RUN dotnet restore "testproject/testproject.csproj"
COPY . .
WORKDIR "/src/testproject"
RUN dotnet build "testproject.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "testproject.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
RUN addgroup --group friendlygroupname --gid 2000 \
&& adduser \    
    --uid 1000 \
    --gid 2000 \
    "friendlyusername" 

RUN chown friendlyusername:friendlygroupname  /app /tmp
USER friendlyusername:friendlygroupname 
ENTRYPOINT ["dotnet", "testproject.dll"]
