# Restro App

A Dockerized Express.js application with MySQL, designed to manage restaurants, dishes, and orders. Features a search API with ranking logic.

## Prerequisites

- Docker
- Docker Compose

## Configuration

The application uses the following environment variables (defined in `docker-compose.yml`):

| Service | Variable | Description | Default |
| :--- | :--- | :--- | :--- |
| **App** | `DB_HOST` | Hostname of the database service | `db` |
| **App** | `DB_USER` | Database username | `root` |
| **App** | `DB_PASSWORD` | Database password | `password` |
| **App** | `DB_NAME` | Name of the database to connect to | `restro_db` |
| **DB** | `MYSQL_ROOT_PASSWORD` | Root password for MySQL | `password` |
| **DB** | `MYSQL_DATABASE` | Database to create on initialization | `restro_db` |

## Getting Started

1.  **Clone the repository** (if not already done).
2.  **Start the services**:

    ```bash
    docker compose up --build
    ```

    This will:
    - Build the Express app image (Node.js 21).
    - Start a MySQL 8.0 container.
    - Initialize the database with schema and sample data (including large dataset generation).
    - Expose the API on port `3001` .

3.  **Stop the services**:

    ```bash
    docker compose down
    ```

    To clear the database volume and reset data:
    ```bash
    docker compose down -v
    ```

## API Endpoints

The application runs on `http://localhost:3001`.

### Data Retrieval

-   `GET /restros`
    -   Returns list of all restaurants.
-   `GET /dishes`
    -   Returns list of all dishes.
-   `GET /orders`
    -   Returns list of all orders.

### Search

-   `GET /search/dishes`
    -   Search for dishes by name within a price range, ranked by order count (popularity).
    -   **Query Parameters**:
        -   `name`: Name of the dish (partial match supported).
        -   `minPrice`: Minimum price.
        -   `maxPrice`: Maximum price.
    -   **Example**:
        ```bash
        curl "http://localhost:3001/search/dishes?name=Biryani&minPrice=150&maxPrice=300"
        ```

## Database Schema

-   **restros**: `id`, `name`, `city`, `address`
-   **dishes**: `id`, `name`, `price`, `restro_id` (FK to restros)
-   **orders**: `id`, `restro_id`, `dish_id` (FK to dishes), `order_time`

## Data Generation

The `init.sql` script includes a Stored Procedure `PopulateData` that automatically generates:
-   ~20 Restaurants
-   ~160 Dishes
-   ~2000 Orders (randomized)

## Deployment

### Deploy to Render

### Deploy to Render

**Note:** Render's Free Tier does not support private MySQL services (`pserv`). You must provision a MySQL database externally (e.g., using [Aiven Free Tier](https://aiven.io/mysql) or a paid Render MySQL instance).

1.  **Create your Database**:
    -   Provision a MySQL database from a provider.
    -   Run the contents of `init.sql` on your new database to set up the schema and data.
2.  **Deploy App**:
    -   Create a **New Blueprint Instance** on [Render dashboard](https://dashboard.render.com/).
    -   Connect your GitHub repository.
    -   Render will detect `render.yaml` and ask for the following environment variables:
        -   `DB_HOST`: Hostname of your external database.
        -   `DB_USER`: Your database username.
        -   `DB_PASSWORD`: Your database password.
    -   The `restro-app` service will be deployed.
3.  Click **Apply**.

Once deployed, your API will be accessible via the URL provided by Render.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
