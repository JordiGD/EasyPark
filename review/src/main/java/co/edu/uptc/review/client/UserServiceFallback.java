package co.edu.uptc.review.client;

import org.springframework.stereotype.Component;

@Component
public class UserServiceFallback implements UserServiceClient {

    @Override
    public UserResponse getUserById(Long id) {
        // En caso de que el user-service falle, devolver una respuesta vacía
        return new UserResponse(id, "Usuario #" + id, "unknown@easypark.com", "UNKNOWN");
    }
}
