package co.edu.uptc.driver.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import co.edu.uptc.driver.entity.Owner;

@Repository
public interface OwnerRepo extends JpaRepository<Owner, Long> {
    
}
